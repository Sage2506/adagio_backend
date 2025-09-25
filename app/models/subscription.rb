class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :alumn
  has_many :subscription_payments
  has_many :payments, through: :subscription_payments
  before_create :set_defaults
  enum :status, [ :active, :cancelled, :expired ]
  before_create :set_paid_at_if_blank

  def set_defaults
    self.status = 0
    if plan&.subscription_duration
      self.due_date = Date.today + plan.subscription_duration.days
    else
      errors.add(:base, "Plan or subscription duration missing")
      throw(:abort) # Prevents saving if no plan/duration is set
    end
  end

  def fully_paid?
    paid_amount >= plan.price
  end

  def remaining_balance
    [ plan.price - paid_amount, 0 ].max
  end

  def payment_percentage
    (paid_amount / plan.price * 100).round(2)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[alumn_id plan_id]
  end

  # `ransackable_associations` returns the names
  # of searchable associations as an array of strings.
  #
  def self.ransackable_associations(auth_object = nil)
    %w[alumn plan]
  end

  # `ransortable_attributes` by default returns the names
  # of all attributes available for sorting as an array of strings.
  #
  def self.ransortable_attributes(auth_object = nil)
    ransackable_attributes(auth_object)
  end

  # `ransackable_scopes` by default returns an empty array
  # i.e. no class methods/scopes are authorized.
  # For overriding with an allowlist, return an array of *symbols*.
  #
  def self.ransackable_scopes(auth_object = nil)
    []
  end

  private
  def set_subscribed_at_if_blank
    self.subscribed_at ||= created_at
  end
end
