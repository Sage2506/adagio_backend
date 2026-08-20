class Order < ApplicationRecord
  belongs_to :alumn
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  has_many :order_payments, dependent: :restrict_with_error
  has_many :payments, through: :order_payments
  enum :status, %w[pending partial paid]

  validates :total, numericality: { greater_than: 0 }
  validates :paid_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  validate :paid_amount_does_not_exceed_total

  def remaining_balance
    [ total - paid_amount, 0 ].max
  end

  def register_payment!(payment)
    with_lock do
      validate_payment!(payment)
      OrderPayment.create!(order: self, payment: payment)
      self.paid_amount += payment.quantity
      recalculate_payment_status!
    end
  end

  def recalculate_payment_status!
    self.status = if paid_amount.zero?
      :pending
    elsif paid_amount < total
      :partial
    else
      :paid
    end

    save!
  end

  private

  def validate_payment!(payment)
    reject_payment!("Payment must be persisted") unless payment&.persisted?
    reject_payment!("Payment alumn must match order alumn") unless payment.alumn_id == alumn_id
    reject_payment!("Order is already paid") if paid?
    reject_payment!("Payment quantity must be greater than zero") unless payment.quantity&.positive?
    reject_payment!("Payment quantity exceeds remaining balance") if payment.quantity.to_d > remaining_balance
  end

  def reject_payment!(message)
    errors.add(:base, message)
    raise ActiveRecord::RecordInvalid, self
  end

  def paid_amount_does_not_exceed_total
    return if total.blank? || paid_amount.blank? || paid_amount <= total

    errors.add(:paid_amount, "cannot exceed total")
  end
end
