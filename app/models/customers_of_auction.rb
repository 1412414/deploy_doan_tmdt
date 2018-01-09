class CustomersOfAuction < ApplicationRecord
	belongs_to :customer
	belongs_to :auction
	has_many :auction_details, dependent: :destroy
end
