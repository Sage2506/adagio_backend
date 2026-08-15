class Payment < ApplicationRecord
  belongs_to :alumn
  has_one :subscription_payment, dependent: :destroy
  has_one :subscription, through: :subscription_payment
  has_one :order_payment, dependent: :restrict_with_error
  has_one :order, through: :order_payment
  validates :quantity, numericality: { greater_than: 0 }
  validate :immutable_when_linked_to_order, on: :update
  before_create :set_paid_at_if_blank

  def payable
    subscription || order
  end

  private

  def immutable_when_linked_to_order
    errors.add(:base, "Order payments cannot be modified") if order_payment.present?
  end

  def set_paid_at_if_blank
    self.paid_at ||= created_at
  end
end
