class ComplaintController < ApplicationController
	def index
		
		@complaints = Complaint.where(handled: 0)

		render layout: "without_sidebar_carousel"
	end

	def show
		
	end

	def edit

		@complaint = Complaint.find(params[:id])
		@cus = @complaint.customer
		# x = 1;
		# if x == 1
		#    redirect_to "/"
		# else
		#    redirect_to "/complaint"
		# end 
		
		render layout: "without_sidebar_carousel"
	end

	def update
		@complaint = Complaint.find(params[:id])
		@cus = @complaint.customer
		
		dieuchinh = params[:dieuchinh]
		if dieuchinh == 'ngungblock'
			@cus.blocker_id = nil
			@cus.blocking_time = nil
			
		end

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

		@cus.save

		@complaint.handled = 1
		@complaint.save

		gui_message_complaint(@cus.id, params[:giaithich], "Khiếu nại của bạn đã được xử lý")

		redirect_to "/complaint"
	end

	def new
		@cus = Customer.find(session[:id_current_customer])
		
		render layout: "without_sidebar_carousel"
	end

	def create

		complaint = Complaint.create!(id: Complaint.maximum("id") + 1, customer_id: session[:id_current_customer], employee_id: Customer.find(session[:id_current_customer]).blocker_id, complaint_day: DateTime.now, handled: 0, reason: params[:complaint][:reason])

		gui_message_complaint(session[:id_current_customer], "Bạn đã gửi khiếu nại thành công", "Gửi khiếu nại thành công")
	end

	def gui_message_complaint(customerId, content, title)
		p "Bat dau gui message"
		Notification.create!(id: Notification.maximum("id") + 1, title: title, content: content, 
			sending_time: DateTime.now, customer_id: customerId)
	end
end
