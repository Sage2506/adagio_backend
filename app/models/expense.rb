class Expense < ApplicationRecord
  enum :category, {
    rent: 0,
    utilities: 1,
    payroll: 2,
    maintenance: 3,
    commission: 4,
    other: 5
  }

  enum :payment_method, {
    cash: 0,
    transfer: 1,
    card: 2
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, :payment_method, :date, presence: true
end
