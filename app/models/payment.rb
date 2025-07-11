class Payment < ApplicationRecord
  has_one :subscription_payment, dependent: :destroy
  has_one :subscription, through: :subscription_payment
  has_one :order_payment, dependent: :destroy
  has_one :order, through: :order_payment
  validate :does_not_exceed_subscription_balance

  def payable
    subscription || order
  end

  def does_not_exceed_subscription_balance
    return unless payable.respond_to?(:remaining_balance)
    if payable && amount > payable.remaining_balance
      errors.add(:amount, "exceeds remaining balance for #{payable.class.name.downcase}")
    end
  end
end
