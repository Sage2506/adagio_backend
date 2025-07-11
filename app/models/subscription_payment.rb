class SubscriptionPayment < ApplicationRecord
  belongs_to :subscription
  belongs_to :payment
end
