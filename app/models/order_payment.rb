class OrderPayment < ApplicationRecord
  belongs_to :payment
  belongs_to :order
end
