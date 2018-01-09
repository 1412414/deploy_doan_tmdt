class AuctionController < ApplicationController
	def index
		@auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN product_examinations ON products.id = product_examinations.product_id")
			.where("product_examinations.status = 2 and images.id in (select id from images where product_id = products.id order by id DESC limit 1) and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW()")
			.select("auctions.id as auction_id, auctions.current_price, products.description, products.product_name, auctions.created_at, images.*")
			.order("auctions.created_at DESC")
	end

def xemphien
	@auctions = Product.joins("INNER JOIN auctions ON products.id= auctions.product_id and products.customer_id="+ session[:id_current_customer].to_s).
							select("auctions.id as auction_id,auctions.starting_time as auctions_start_time,auctions.ending_time as endtime,auctions.starting_price as start_price,auctions.max_price as max_price,auctions.current_price as auction_current,auctions.status as auction_status,auctions.bid_increment as auction_increment,products.product_name as product_name")
							.where("to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW() and auctions.status = 0 ")
							.order("auctions.created_at DESC")

end
def huyphien
		@phien = Auction.find(params["MaPhien"])


		kh_daugia = CustomersOfAuction.where(:auction_id => params[:MaPhien])
		p kh_daugia
		kh_daugia.each do |kh|
			p "trong each"
			Notification.create!(id: Notification.maximum("id") + 1, title: "Huy dau gia", content: "Phien dau gia da huy", sending_time: Time.NOW, customer_id: kh.customer_id)
		end

		@phien.update(:status => '1')
		redirect_to xemphien_path
end
	def show
		@images = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id")
			.where("auctions.id = " + params["id"])
			.select("auctions.id as auction_id, auctions.*, products.description, products.product_type_id, products.product_name, images.*")

		@customer = Customer.joins("INNER JOIN products ON products.customer_id = customers.id " +
			"INNER JOIN auctions ON products.id = auctions.product_id and auctions.id = " + params["id"])
		.select("customers.*")

		product_type_id = Auction.joins(:product)
			.where("auctions.id = " + params["id"])
			.select("products.product_type_id")[0].product_type_id

		@auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id")
			.where("auctions.id != " + params["id"] + " and images.id in (select id from images where product_id = products.id order by id DESC limit 1)" +
			" and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW() and products.product_type_id = " + product_type_id.to_s)
			.select("auctions.id as auction_id, auctions.current_price, products.description, products.product_name, auctions.created_at, images.*")
			.order("auctions.created_at DESC").limit(9)

		if @auctions.length < 9
			length = 9 - @auctions.length

			category_id = Auction.joins("INNER JOIN products ON products.id = auctions.product_id INNER JOIN product_types ON products.product_type_id = product_types.id")
			.where("auctions.id = " + params["id"])
			.select("product_types.category_id")[0].category_id

			where = "auctions.id != " + params["id"] + " and images.id in (select id from images where product_id = products.id order by id DESC limit 1)" +
			" and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW() and product_types.category_id = " + category_id.to_s + " and auctions.id not in("

			@auctions.each do |a|
				if a.auction_id.to_s != @auctions.last.auction_id.to_s
					where += a.auction_id.to_s + ", "
				else
					where += a.auction_id.to_s
				end
			end


			where += ")"

			@additional_auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN product_types ON product_types.id = products.product_type_id")
				.where(where)
				.select("auctions.id as auction_id, auctions.current_price, products.description, products.product_name, auctions.created_at, images.*")
				.order("auctions.created_at DESC").limit(length)
		end

		render layout: "without_carousel"
	end

	def them_auction_detail(max_id_auctiondetail, id_customerofauction, bidAmount)
		p "Dang them auction detail"

		AuctionDetail.create!(id: max_id_auctiondetail,
						customers_of_auction_id: id_customerofauction,
						bid_time: Time.now, bid_amount: bidAmount, status: 0)
	end

	def tim_customer_co_max_bid_amount(maxBidAmount, auctionId)
		p "Dang tim customer co max bid amount"

		return CustomersOfAuction.select("id, customer_id").where("max_bid_amount = " + maxBidAmount.to_s +
			" and auction_id = " + auctionId)
	end

	def tao_customer_of_auction(max_id_customerofauction, idAuction, customerId, giaCaoNhat)
		p "Tao customer of auction"

		CustomersOfAuction.create!(id: max_id_customerofauction, auction_id: idAuction,
						customer_id: customerId, max_bid_amount: giaCaoNhat)
	end

	def cap_nhat_gia_hien_tai_auction(idAuction, currentPrice)
		Auction.update(idAuction, :current_price => currentPrice)
	end

	def cap_nhat_gia_cao_nhat_cua_khach_hang(idAuction, customerId, maxBidAmount)
		p "Cap nhat gia cao nhat cua khach hang"

		cus = CustomersOfAuction.select("*")
			.where("auction_id = " + idAuction + " and customer_id = " + customerId.to_s)

		p cus

		if cus[0].max_bid_amount < Integer(maxBidAmount)

			p "Gia cao nhat cu nho hon gia cao nhat moi"

			cus[0].max_bid_amount = maxBidAmount

			cus[0].save

		end
	end

	def them_bid(max_id_customerofauction, max_id_auctiondetail, idAuction, customerId, giaCaoNhat, gia)

		p "Dang trong them bid"

		id_customerofauction = CustomersOfAuction.select("id").where("auction_id = " + idAuction +
			" and customer_id = " + customerId.to_s)

		if id_customerofauction.any? == true

			p "Khach hang da tung bid tren auction nay"

			# Cập nhật lài giá cao nhất của khách hàng
			cap_nhat_gia_cao_nhat_cua_khach_hang(idAuction, customerId, giaCaoNhat)

			# Sau đó thêm một auction detail mới
			them_auction_detail(max_id_auctiondetail, id_customerofauction[0].id, gia)

			# Cập nhật lại giá cao nhất của auction này
			cap_nhat_gia_hien_tai_auction(idAuction, gia)

		else

			p "Khach hang chua tung bid tren auction nay"

			# Nếu chưa tồn tại khách hàng này thì thêm một khách hàng mới vào
			tao_customer_of_auction(max_id_customerofauction, idAuction,
						customerId, giaCaoNhat)

			# Sau đó thêm một auction detail mới cho khách hàng mới này
			them_auction_detail(max_id_auctiondetail, max_id_customerofauction, gia)

			# Cập nhật lại giá cao nhất của auction này
			cap_nhat_gia_hien_tai_auction(idAuction, gia)

		end

	end

	def gui_message_outbid(customerId, content, title)

		p "Bat dau gui message"
		Notification.create!(id: Notification.maximum("id") + 1, title: title, content: content,
			sending_time: Time.now, customer_id: customerId)

	end

	def bid

		p "Bat dau bidding"

		auction = Auction.select("id, current_price, starting_time, ending_time")
			.where("id = " + params["IdAuction"])

		p auction

		if Time.now < auction[0].starting_time.to_time || Time.now > auction[0].ending_time.to_time
			p Time.now

			flash[:bidding_message] = "Thời gian đấu giá chưa bắt đầu hoặc đã kết thúc"
			redirect_back fallback_location: { action: "show", id: params["IdAuction"] }

		elsif Integer(params["Gia"]) <= auction[0].current_price

			p "Gia nho hon hoac bang gia hien tai"

			flash[:bidding_message] = "Không được ra giá nhỏ hơn hoặc bằng giá hiện tại"
			redirect_back fallback_location: { action: "show", id: params["IdAuction"] } # Không được ra giá nhỏ hơn hoặc bằng giá hiện tại

		else

			p "Gia lon hon gia hien tai"

			# Lấy ra giá lớn nhất lớn nhất hiện tại
			max_bid_amount = CustomersOfAuction.select("max(max_bid_amount) as max_bid_amount")
				.where("auction_id = " + params["IdAuction"])[0].max_bid_amount

			p max_bid_amount

			max_id_auctiondetail = AuctionDetail.maximum("id") + 1
			max_id_customerofauction = CustomersOfAuction.maximum("id") + 1

			# Trường hợp có một người đặt giá cao nhất
			if max_bid_amount.present? && max_bid_amount != 0
				customer = tim_customer_co_max_bid_amount(max_bid_amount,
					params["IdAuction"])

				p "Va co nguoi nao do dat gia lon nhat"

				if Integer(params["Gia"]) > max_bid_amount
					p "Gia minh ra lon hon gia lon nhat nen minh thang"

					if customer[0].customer_id != session[:id_current_customer]
						gui_message_outbid(customer[0].customer_id, "Bạn đã bị outpid", "Đấu giá " +
							params["IdAuction"] + " bị outpid")
					end

					# Nếu giá mình ra cao hơn giá lớn nhất của tất cả các khách hàng khác thì thêm vào
					them_bid(max_id_customerofauction, max_id_auctiondetail,
						params["IdAuction"], session[:id_current_customer], params["GiaCaoNhat"], params["Gia"])

					flash[:bidding_message] = "Đấu giá thành công"
					redirect_back fallback_location: { action: "show", id: params["IdAuction"] } # Thêm thành công

				else
					p "Gia minh lon hon gia hien tai nhung nho hon gia lon nhat cua nguoi khac"

					# Nếu giá lớn nhất của mình cao hơn giá lớn nhất của người khác thì lấy giá lớn nhất
					# của người đó cộng thêm với bước giá
					if Integer(params["GiaCaoNhat"]) > max_bid_amount

						p "Gia cao nhat cua minh lon hon gia cao nhat cua nguoi khac"

						if customer[0].customer_id != session[:id_current_customer]
							gui_message_outbid(customer[0].customer_id, "Bạn đã bị outpid", "Đấu giá " +
								params["IdAuction"] + " bị outbid")
						end

						# Lấy giá cao nhất cộng với bước giá
						them_bid(max_id_customerofauction, max_id_auctiondetail, params["IdAuction"], session[:id_current_customer],
							params["GiaCaoNhat"], max_bid_amount + Integer(params["BuocGia"]))

						flash[:bidding_message] = "Đấu giá thành công"
						redirect_back fallback_location: { action: "show", id: params["IdAuction"] } # Thêm thành công

					else

						p "Gia cao nhat cua minh nho hon gia cao nhat cua nguoi khac"

						# Nếu giá lớn nhất của mình nhỏ hơn giá lớn nhất của người ta thì báo là đã thay đổi
						# Kiếm thằng có max_bid_amount tăng giá nó lên
						# Lấy giá mình nhập cộng với bước giá
						them_auction_detail(max_id_auctiondetail, customer[0].id,
							Integer(params["Gia"]) + Integer(params["BuocGia"]))

						cap_nhat_gia_hien_tai_auction(params["IdAuction"], Integer(params["Gia"]) +
						 Integer(params["BuocGia"]))

						if customer[0].customer_id != session[:id_current_customer]
							flash[:bidding_message] = "Giá đã thay đổi"
						else
							flash[:bidding_message] = "Đấu giá thành công"
						end

						redirect_back fallback_location: { action: "show", id: params["IdAuction"] } # Báo là giá đã thay đổi
					end
				end
			else

				# Trường hợp không có người nào đặt giá cao nhất
				p "Khong co nguoi nao dat gia cao nhat"

				CustomersOfAuction.where("auction_id = " + params["IdAuction"]).each do |c|
					if c.customer_id != session[:id_current_customer]
						gui_message_outbid(c.customer_id, "Bạn đã bị outbid", "Đấu giá " +
							params["IdAuction"] + " bị outbid")
					end
				end

				them_bid(max_id_customerofauction, max_id_auctiondetail, params["IdAuction"], session[:id_current_customer],
							params["GiaCaoNhat"], params["Gia"])

				flash[:bidding_message] = "Đấu giá thành công"
				redirect_back fallback_location: { action: "show", id: params["IdAuction"] } # Thêm thành công

			end
		end

	end

	def buy_it_now
		p "Mua ngay"

		# Lấy ra giá lớn nhất lớn nhất hiện tại, không tính của mình
		max_bid_amount = CustomersOfAuction.select("max(max_bid_amount) as max_bid_amount")
			.where("auction_id = " + params["auction_id"])[0].max_bid_amount

		p max_bid_amount

		max_id_customerofauction = CustomersOfAuction.maximum("id") + 1
		max_id_auctiondetail = AuctionDetail.maximum("id") + 1

		customer = tim_customer_co_max_bid_amount(max_bid_amount,
							params["auction_id"])

		buy_it_now_price = Auction.select("buy_it_now_price")
			.where("id = " + params["auction_id"])[0].buy_it_now_price

		if max_bid_amount.present? && max_bid_amount != 0
			p "Co nguoi dau gia cao nhat"

			if customer[0].customer_id != session[:id_current_customer]
				gui_message_outbid(customer[0].customer_id, "Bạn đã bị outbid", "Đấu giá " +
					params["auction_id"] + " bị outbid")
			end
		else
			p "Khong co nguoi dau gia cao nhat"

			CustomersOfAuction.where("auction_id = " + params["auction_id"]).each do |c|
				if c.customer_id != session[:id_current_customer]
					gui_message_outbid(c.customer_id, "Bạn đã bị outbid", "Đấu giá " +
						params["auction_id"] + " bị outbid")
				end
			end
		end

		them_bid(max_id_customerofauction, max_id_auctiondetail, params["auction_id"], session[:id_current_customer],
			buy_it_now_price, buy_it_now_price)

		p "Chuan bi cap nhat gia hien tai va thoi gian ket thuc"

		Auction.update(params["auction_id"], :ending_time => Time.now)


		p "Bat dau tao hoa don"

		Receipt.create!(id: Receipt.maximum("id") + 1, auction_id: params["auction_id"], customer_id: session[:id_current_customer],
		 card_number: nil, product_received: 0, status: 0, total_amount: buy_it_now_price)

		Invoice.create!(id: Invoice.maximum("id") + 1, receipt_id: Receipt.maximum("id"),
			card_number: nil, total_amount: buy_it_now_price * 5 / 100, status: 0)

		flash[:bidding_message] = "Mua ngay thành công"
		redirect_back fallback_location: { action: "show", id: params["auction_id"] } # Thêm thành công
	end

	def timKiem
		if (params[:search][:search_category] == "Tất cả")
			p "Tatca"

			@auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN product_examinations ON products.id = product_examinations.product_id")
				.where("product_examinations.status = 2 and images.id in (select id from images where product_id = products.id order by id DESC limit 1) and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW() and lower(products.product_name) like lower('%" + params[:search][:search_key] + "%')")
				.select("auctions.id as auction_id, auctions.current_price, products.description, products.product_name, auctions.created_at, images.*")
				.order("auctions.created_at DESC")
		else
			@auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN product_examinations ON products.id = product_examinations.product_id INNER JOIN product_types ON product_types.id = products.product_type_id INNER JOIN categories ON categories.id = product_types.category_id")
				.where("product_examinations.status = 2 and images.id in (select id from images where product_id = products.id order by id DESC limit 1) and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW() and lower(products.product_name) like lower('%" + params[:search][:search_key] + "%') and lower(categories.category_name) like lower('%" + params[:search][:search_category] + "%')")
				.select("auctions.id as auction_id, auctions.current_price, products.description, products.product_name, auctions.created_at, images.*")
				.order("auctions.created_at DESC")

			render layout: "without_carousel"
		end
	end

	def getTimKiem
		redirect_to "/"
	end
end
