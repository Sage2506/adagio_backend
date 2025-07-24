class Order < ApplicationRecord
  has_one :alumn
  has_many :order_payments
  has_many :payments, through: :order_payments
  enum :status, %w[ pending partial paid]
end
