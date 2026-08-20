class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }
end
