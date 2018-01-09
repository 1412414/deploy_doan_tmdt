class NotificationController < ApplicationController
	def index
		@notifications = Notification.select("*")
						.where("customer_id = " + params["customer_id"])
						.order("sending_time DESC")

		render layout: "without_carousel"
	end
end
