class Order < ApplicationRecord
  has_one :alumn
  has_many :order_payments
  has_many :payments, through: :order_payments
  enum :status, %w[ pending partial paid]

  def remaining_balance
    [ total - paid_amount, 0].max
  end
end
