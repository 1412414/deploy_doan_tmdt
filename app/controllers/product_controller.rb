class ProductController < ApplicationController
	def new
		@danhmuc = Category.all;

		render layout: "without_sidebar_carousel"
	end

	def edit
		render layout: "without_sidebar_carousel"
	end
	def xemsp

				@sanpham = ProductType.joins("INNER JOIN products ON products.product_type_id = product_types.id INNER JOIN categories ON categories.id  = product_types.category_id")
				.where("customer_id = " + session[:id_current_customer].to_s)
				.select("products.id as product_id, products.product_name,products.description,product_types.product_type_name,categories.category_name ")
			end

			def Update_San_Pham
				@product = Product.find(params["MaSP"])
				@product.product_name = params["TenSP"]
				@product.description = params["MoTa"]

				if @product.save
					flash[:success] = "Update product successfully"
					redirect_to xemsp_path
				else
					flash[:error] = "Cannot update product"
					redirect_to xemsp_path
				end
			end

	def create
		p params
		productId = Product.maximum("id") + 1
		Product.create!(id: productId, product_name: params["TenSanPham"],
			description: params["MoTa"], product_type_id: params["LoaiSanPham"], customer_id: Integer(session[:id_current_customer]))
		p "Thêm xong sản phẩm"

		productExaminationId = ProductExamination.maximum("id") + 1
		ProductExamination.create!(id: productExaminationId, examination_time: nil, product_id: productId, employee_id: nil, reason: "", status: 0)

		imageId = Image.maximum("id") + 1
		images = params["HinhAnh"]

		p images

		images.each do |i|
			Image.create!(id: imageId, image: i, product_id: productId)

			imageId += 1
		end

		p "Thêm xong hình ảnh"

		auctionId = Auction.maximum("id") + 1

		auctions = params["Phien"]

		auctions.each do |a|
			p a

			Auction.create!(id: auctionId, ending_time: a["ThoiGianKetThuc"].gsub!('T',' '),
				starting_time: a["ThoiGianBatDau"].gsub!('T',' '),
				starting_price: a["GiaKhoiDiem"], current_price: a["GiaKhoiDiem"], max_price: a["GiaTran"], buy_it_now_price: params["GiaMuaNgay"],
				bid_increment: a["BuocGia"], status: 0, product_id: productId)

			p "Thoi gian ket thuc chuyen qua to_time: "
			p a["ThoiGianKetThuc"].to_time

			auctionId += 1
		end

		redirect_to action: "new"
	end
	private
	def product_edit_params
		params.require(:product).permit(:product_name, :description)
	end

end
