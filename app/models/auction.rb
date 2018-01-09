class Auction < ApplicationRecord
  	belongs_to :product
    has_many :customers_of_auctions, dependent: :destroy
    has_many :favorite_lists, dependent: :destroy
end
