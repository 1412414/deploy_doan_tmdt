class AuctionDetailController < ApplicationController
	def index
		@auction_details = AuctionDetail.select("auction_details.*, customers_of_auctions.*").joins(:customers_of_auction).where("auction_id = " + params["auction_id"])

		render layout: "without_carousel"
	end
	def xem
	@detail = CustomersOfAuction.joins("INNER JOIN auction_details on auction_details.customers_of_auction_id = customers_of_auctions.id INNER JOIN auctions on  auctions.id = customers_of_auctions.auction_id INNER JOIN  products on auctions.product_id = products.id ")
	.select("auctions.current_price as max_bid,customers_of_auctions.auction_id as auction_id,customers_of_auctions.customer_id as customer_id,products.product_name as product_name,auction_details.status as status,auction_details.id as detail_id,auctions.ending_time as ending_time,customers_of_auctions.customer_id as customer_id ")
	.where("to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW() and auction_details.status = 0  and auction_details.bid_amount = auctions.current_price and customers_of_auctions.customer_id= "+ session[:id_current_customer].to_s)
	.order("auctions.created_at DESC")
end
 def huydaugia
	 @daugia = AuctionDetail.find(params["MaDetail"])
	 @daugia.update(:status => '1')
	 temp = CustomersOfAuction	.joins("INNER JOIN auction_details on customers_of_auctions.id = auction_details.customers_of_auction_id INNER JOIN auctions on auctions.id = customers_of_auctions.auction_id ").where("auction_details.status = 0 and auctions.id="+ params["Auction_ID"]).maximum("bid_amount")
	 giahientai = Auction.find(params["Auction_ID"])
	 giahientai.update(:current_price => temp)
	 redirect_to xem_daugia_path

 end

end
