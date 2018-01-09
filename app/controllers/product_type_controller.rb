class ProductTypeController < ApplicationController
	def show
		@auctions = Image.joins("INNER JOIN products ON products.id = images.product_id INNER JOIN auctions ON products.id = auctions.product_id INNER JOIN product_examinations ON products.id = product_examinations.product_id")
			.where("product_examinations.status = 2" + 
				" and images.id in (select id from images where product_id = products.id order by id DESC limit 1)" +
				" and to_timestamp(ending_time,'yyyy-mm-dd HH24:MI:ss') > NOW()" +
				" and product_type_id = " + params[:id])
			.select("auctions.id as auction_id, auctions.current_price, products.description, products.product_name, auctions.created_at, images.*")
			.order("auctions.created_at DESC")

		render layout: "without_carousel"
	end
end