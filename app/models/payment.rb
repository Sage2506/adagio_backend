class Payment < ApplicationRecord
  belongs_to :alumn

  enum :payment_method, { cash: 0, transfer: 1, card: 2 }

  has_one :subscription_payment, dependent: :destroy
  has_one :subscription, through: :subscription_payment
  has_one :order_payment, dependent: :restrict_with_error
  has_one :order, through: :order_payment
  validates :quantity, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :reference, uniqueness: true, allow_nil: true
  validate :immutable_when_linked_to_order, on: :update
  before_create :set_paid_at_if_blank
  before_validation :set_default_payment_method, on: :create
  scope :by_method, ->(method) { where(payment_method: payment_methods[method]) if method.present? }
  scope :cash_payments, -> { where(payment_method: :cash) }
  scope :online_payments, -> { where(payment_method: [ :transfer, :card ]) }
  scope :pending, -> { where(paid_at: nil) }
  scope :completed, -> { where.not(paid_at: nil) }

  def payable
    subscription || order
  end

  # ===== MÉTODOS DE INSTANCIA =====
  def online_payment?
    transfer? || card?
  end

  def cash_payment?
    cash?
  end

  def transfer_payment?
    transfer?
  end

  def payment_method_name
    I18n.t("activerecord.attributes.payment.payment_methods.#{payment_method}")
  end

  before_validation :set_default_payment_method, on: :create

  private

  def immutable_when_linked_to_order
    errors.add(:base, "Order payments cannot be modified") if order_payment.present?
  end

  def set_paid_at_if_blank
    self.paid_at ||= created_at
  end

  def set_default_payment_method
    self.payment_method ||= :cash
  end
end
