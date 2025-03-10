class SubscriptionPayment < ApplicationRecord
  belongs_to :subcription
  belongs_to :payment
end
