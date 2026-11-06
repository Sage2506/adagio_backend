class AdditionalIncome < ApplicationRecord
  enum :category, {
    space_rental: 0,
    events: 1,
    initial_balance: 2,
    other: 3,
    late_fees: 4,
    merchandise: 5,
    plan_upgrade: 6,
    owner_contribution: 7,
    financial_yields: 8
  }

  enum :payment_method, {
    cash: 0,
    transfer: 1,
    card: 2
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, :payment_method, :date, presence: true
end
