Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/', to: 'auction#index'
  post '/TimKiem', to: 'auction#timKiem'
  get '/TimKiem', to: 'auction#getTimKiem'
  get '/session/login', to: 'session#new', as: :login
  post '/session/login', to: 'session#create', as: nil

  delete '/session/logout', to: 'session#destroy', as: :logout
  #Xem Phien va Huy Phien dau gia
  get '/auction/xemphien', to: 'auction#xemphien', as: :xemphien
  post '/auction/delete', to: 'auction#huyphien', as: :huyphien
	get '/customer/new', to: 'customer#new', as: :new_customer
  #Xem va Huy Dau Gia
  post'/auction_detail/huydaugia', to: 'auction_detail#huydaugia'
  get'/auction_detail/xem',to: 'auction_detail#xem', as: :xem_daugia

	#get '/customers', to: 'users#show', as: :users
	# get '/users/:id', to: 'users#show', as: :users

	post '/customer', to: 'customer#create', as: :create_customer

	get '/customer/show', to: 'customer#showaccountinf', as: :customer_show

	get '/customer/edit/:id', to: 'customer#edit', as: :customer_edit
	post '/customer/edit/:id', to: 'customer#update', as: :customer_update

	get '/customer/showauction', to: 'customer#showauction', as: :customer_show_auction
	get '/customer/showauctioning', to: 'customer#showauctioning', as: :customer_show_auctioning

  get '/customer/showallproduct', to: 'customer#showallproduct', as: :customer_showproduct
  get '/customer/showsoldproduct', to: 'customer#showsoldproduct', as: :customer_showsoldproduct

  get '/customer/showfavoritelist', to: 'customer#showfavoritelist', as: :customer_showfavlist
  post '/customer/favoritelist', to: 'favorite_list#create', as: :create_favlist

#update san pham
	post 'product/updatesp', to: 'product#Update_San_Pham', as: :product_update
  get 'product/xemsp', to: 'product#xemsp', as: :xemsp
 	# Tạo ra categories và category/:id/product_type
 	resources :category do
 		collection do
 			post 'get_product_type'
 		end

 		resources :product_type
 	end

 	# Tạo ra /customer và /customer/:id/product và /customer/:id/auction, ....
 	resources :customer do
 		resources :product
 		resources :auction
 		resources :favorite_list
 		resources :receipt do
 			get 'pay'
 			post 'hook'
 			resources :report
 		end

 		resources :invoice
 		# resources :report
 		resources :review
 		resources :notification
 	end

 	# Tạo ra /employee/:id/complaint
 	# resources :employee do
 	# 	resources :complaint
 	# end

 	# Tạo ra /auction
 	resources :auction do
 		collection do
 			post 'bid'
 		end

 		post 'buy_it_now'

 		resources :auction_detail
 	end

 	resources :product_examination

 	resources :complaint

 	get '/staffreport', to: 'staffreport#index'
 	get '/staffreport/profit', to: 'staffreport#profit'
 	get '/staffreport/revenue', to: 'staffreport#revenue'

 	get '/handlereport', to: 'handlereport#index'
 end
