class StaffreportController < ApplicationController

	def index
		render layout: "without_sidebar_carousel"
	end

	def profit
		@n_vip = Customer.where(customer_type: "vip").count
		@n_thuong = Customer.count - @n_vip
		@dichvu_vip = 500000 * @n_vip
		@dichvu_thuong = 100000 * @n_thuong
		@dichvu_tong = @dichvu_vip + @dichvu_thuong

		@phitrunggian_tong = 0
		@phitrunggian_list ||= []
		# invoices = Invoice.all
		invoices = Invoice.where(status: 1)
		# i = 0
		for invoice in invoices do
			price = invoice.total_amount
			fee = 0.1 * price
			@phitrunggian_tong += fee
		end

		@revenue_tong = @dichvu_tong + @phitrunggian_tong

		@profit = @revenue_tong - 10000
		render layout: "without_sidebar_carousel"
	end

	def revenue
		@n_vip = Customer.where(customer_type: "vip").count
		@n_thuong = Customer.count - @n_vip
		@dichvu_vip = 500000 * @n_vip
		@dichvu_thuong = 100000 * @n_thuong
		@dichvu_tong = @dichvu_vip + @dichvu_thuong

		@phitrunggian_tong = 0
		@phitrunggian_list ||= []
		# invoices = Invoice.all
		invoices = Invoice.where(status: 1)
		# @inv = Invoice.where(status: 1)
		i = 0
		for invoice in invoices do
			i = i + 1
			product = invoice.receipt.auction.product.product_name
			customer = invoice.receipt.auction.product.customer.customer_name
			price = invoice.total_amount
			fee = 0.1 * price
			@phitrunggian_tong += fee
			@phitrunggian_list.push({i: i, product: product, customer: customer, price: price, fee: fee})
		end

		@revenue_tong = @dichvu_tong + @phitrunggian_tong

		render layout: "without_sidebar_carousel"
	end
end
