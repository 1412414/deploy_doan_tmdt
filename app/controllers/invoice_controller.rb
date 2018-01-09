class InvoiceController < ApplicationController
	def index
		@invoices = Invoice.select("products.product_name, receipts.auction_id, receipts.id as receipt_id, receipts.total_amount as receipt_total_amount, invoices.total_amount as invoice_total_amount")
						.joins("INNER JOIN receipts ON receipts.id = invoices.receipt_id" +
						" INNER JOIN auctions ON receipts.auction_id = auctions.id" +
						" INNER JOIN products ON products.id = auctions.product_id")
						.where("products.customer_id = " + params["customer_id"] + " and invoices.status <> 1")
						.order("invoices.created_at DESC")

		render layout: "without_carousel"
	end
end
