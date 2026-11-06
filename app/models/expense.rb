class Expense < ApplicationRecord
  enum :category, {
    rent: 0,
    utilities: 1,
    payroll: 2,
    maintenance: 3,
    commission: 4,
    other: 5,
    event_participation: 6,
    celebrations: 7,
    personal_withdrawals: 8,
    inventory_purchases: 9,
    reconciliations: 10
  }

  enum :payment_method, {
    cash: 0,
    transfer: 1,
    card: 2
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, :payment_method, :date, presence: true
end
