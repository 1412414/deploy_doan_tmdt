class CustomerController < ApplicationController
	layout "account"
	before_action :authenticate, only: [:show, :index]
  
  def index
    
  end

  def showaccountinf    
    @customer = Customer.find(session[:id_current_customer])        
  end

  def showauction 
    @auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN customers ON products.customer_id = customers.id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN customers_of_auctions ON auctions.id = customers_of_auctions.auction_id INNER JOIN product_examinations ON products.id = product_examinations.product_id")
    .where("customers_of_auctions.customer_id = " + session[:id_current_customer].to_s + " and product_examinations.status = 2 and images.id in (select id from images where product_id = products.id order by id DESC limit 1) and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') < NOW()")
    .select("DISTINCT customers.customer_name, auctions.id as auction_id, auctions.current_price, auctions.starting_time, auctions.ending_time, products.description, products.product_name, auctions.created_at, images.*")
    .order("auctions.created_at DESC") 
  end

  def showauctioning
    @auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN customers ON products.customer_id = customers.id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN customers_of_auctions ON auctions.id = customers_of_auctions.auction_id INNER JOIN product_examinations ON products.id = product_examinations.product_id")
    .where("customers_of_auctions.customer_id = " + session[:id_current_customer].to_s + " and product_examinations.status = 2 and images.id in (select id from images where product_id = products.id order by id DESC limit 1) and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') >= NOW() and to_timestamp(starting_time, 'yyyy-mm-dd HH24:MI:ss') < NOW()")
    .select("DISTINCT customers.customer_name, auctions.id as auction_id, auctions.current_price, auctions.starting_time, auctions.ending_time, products.description, products.product_name, auctions.created_at, images.*")
    .order("auctions.created_at DESC") 

  end

  def showallproduct
    @products = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN customers ON customers.id = products.customer_id INNER JOIN product_types ON products.product_type_id = product_types.id INNER JOIN product_examinations ON products.id = product_examinations.product_id")
    .where("customers.id = " + session[:id_current_customer].to_s + "and product_examinations.status = 2")
    .select("DISTINCT ON (products.id) products.id as product_id, customers.customer_name, products.product_name, products.description, products.created_at, product_types.product_type_name, images.*")
    .order("products.id DESC")
  end

  def showsoldproduct
    @products = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN customers ON customers.id = products.customer_id INNER JOIN product_types ON products.product_type_id = product_types.id INNER JOIN product_examinations ON products.id = product_examinations.product_id INNER JOIN auctions ON auctions.product_id = products.id")
    .where("customers.id = " + session[:id_current_customer].to_s + "and product_examinations.status = 2 and to_timestamp(ending_time, 'yyyy-mm-dd HH24:MI:ss') < NOW() and auctions.status = 0")
    .select("DISTINCT ON (products.id) products.id as product_id, customers.customer_name, products.product_name, products.description, products.created_at, product_types.product_type_name, images.*")
    .order("products.id DESC")
  end

  def showfavoritelist
    @lists = Image.joins("INNER JOIN auctions ON auctions.product_id = images.product_id INNER JOIN favorite_lists ON favorite_lists.auction_id = auctions.id INNER JOIN products ON products.id = images.product_id INNER JOIN customers ON customers.id = products.customer_id INNER JOIN product_examinations ON product_examinations.product_id = images.product_id")
    .where("favorite_lists.customer_id = " + session[:id_current_customer].to_s + "and product_examinations.status = 2")
    .select("DISTINCT ON (auctions.id) auctions.id as auction_id, auctions.current_price, auctions.starting_time, auctions.ending_time, customers.customer_name, products.description, products.product_name, auctions.created_at, images.*")
    .order("auctions.id DESC") 
  end

  def new
    render layout: "without_sidebar_carousel"
  end

  def create
  	customer = Customer.find_by(customer_email_params)

    if customer.nil?
      @customer =  Customer.new(customer_params)

      max_id =  Customer.maximum("id");
      max_id += 1

      @customer["id"] = max_id
      @customer.password =  customer_pass_params;

      if @customer.save
        redirect_to login_path
      else
        flash[:signup_error] = "Cannot register new account."
        render :new
      end
    else
      flash[:signup_error] = "Email has existed!!!"
      render :new
    end
  end

  def edit
    @customer = Customer.find(session[:id_current_customer])
    render layout: "without_sidebar_carousel"
  end

  def update
    @customer = Customer.find(session[:id_current_customer])
    if @customer.update(customer_edit_params)
      flash[:success] = "Update customer successfully"
      redirect_to customer_show_path
    else
      flash[:error] = "Cannot update customer"
      render :showaccountinf
    end
  end

  private
  def customer_email_params
    params.require(:customer).permit(:username)
  end

  private
  def customer_pass_params
    params.require(:customer).permit(:password)
  end

  private
  def customer_params
  	params.require(:customer).permit(:customer_type, :customer_name, :username, :password)
  end

  private
  def customer_edit_params
    params.require(:customer).permit(:customer_type, :customer_name, :email, :password, :address, :shipping_address)
  end

  def authenticate
    if session[:id_current_customer]
      redirect_to login_path
    end
  end
end
