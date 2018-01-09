class ReportController < ApplicationController
	def show
		@report = Report.joins("INNER JOIN customers ON customers.id = reports.reporter_id")
		.select("reports.*, customers.customer_name as reporter_name, customers.id as reporter_id")
		.joins("INNER JOIN customers abc ON abc.id = reports.reported_customer_id")
		.select("abc.customer_name as reported").find(params[:id])

		render layout: "without_sidebar_carousel"
	end

	def update
		@report = Report.find(params[:id])
		# @report.employee_id = session[:id_current_employee] ####################### LƯU NHÂN VIÊN XỬ LÝ BÁO CÁO
		@report.save

		@cus = Customer.find(@report.reported_customer_id)

		dieuchinh = params[:dieuchinh]
		if dieuchinh == 'block3ngay'
			@cus.blocking_time = @cus.updated_at.to_date + 3.days
		end

		if dieuchinh == 'block1tuan'
			@cus.blocking_time = @cus.updated_at.to_date + 7.days
		end

		if dieuchinh == 'block2tuan'
			@cus.blocking_time = @cus.updated_at.to_date + 14.days
		end

		if dieuchinh == 'block1thang'
			@cus.blocking_time = @cus.updated_at.to_date + 30.days
		end

		if dieuchinh == 'blockvinhvien'
			@cus.blocking_time = @cus.updated_at.to_date + 10.years
		end

		# @cus.blocker_id = session[:id_current_employee] ####################### LƯU NHÂN VIÊN BLOCK TÀI KHOẢN

		@cus.save

		gui_message_report(@cus.id, params[:giaithich], "Bạn bị khóa tài khoản tới " + @cus.blocking_time)

		redirect_to "/handlereport"
	end

	def gui_message_report(customerId, content, title)
		p "Bat dau gui message"
		Notification.create!(id: Notification.maximum("id") + 1, title: title, content: content, 
			sending_time: DateTime.now, customer_id: customerId)
	end
end
