class HandlereportController < ApplicationController
	def index
		# @reports = Report.where(employee_id: nil)

		@reports = Report.where(employee_id: nil)
							.joins("INNER JOIN customers ON customers.id = reports.reporter_id")
							.select("reports.*, customers.customer_name as reporter_name, customers.id as reporter_id")
							.joins("INNER JOIN customers abc ON abc.id = reports.reported_customer_id")
							.select("abc.customer_name as reported")

		render layout: "without_sidebar_carousel"
	end
end
