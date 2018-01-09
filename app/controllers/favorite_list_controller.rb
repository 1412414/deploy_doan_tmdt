class FavoriteListController < ApplicationController
	def index
	end

	def create
		if session[:id_current_customer].nil?
			render json: "2"
		else
			FavoriteList.create!(customer_id: session[:id_current_customer], auction_id: params[:auction_id])

			render json: "1"
		end
	end
end
