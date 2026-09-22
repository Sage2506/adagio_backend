class Api::V1::BalancesController < ApplicationController
  before_action :authenticate_request!

  def show
    # Consultas usando la lógica de Copilot (incluyendo :card)
    student_cash = Payment.where(payment_method: :cash).sum(:quantity)
    student_digital = Payment.where(payment_method: [ :transfer, :card ]).sum(:quantity)

    extra_cash = AdditionalIncome.where(payment_method: :cash).sum(:amount)
    extra_digital = AdditionalIncome.where(payment_method: [ :transfer, :card ]).sum(:amount)

    expense_cash = Expense.where(payment_method: :cash).sum(:amount)
    expense_digital = Expense.where(payment_method: [ :transfer, :card ]).sum(:amount)

    cash_on_hand = (student_cash + extra_cash) - expense_cash
    in_bank_account = (student_digital + extra_digital) - expense_digital

    render json: {
      data: {
        summary: {
          total_available: cash_on_hand + in_bank_account,
          cash_on_hand: cash_on_hand,
          in_bank_account: in_bank_account
        },
        breakdown: {
          student_income: {
            total: student_cash + student_digital,
            cash: student_cash,
            digital: student_digital
          },
          additional_income: {
            total: extra_cash + extra_digital,
            cash: extra_cash,
            digital: extra_digital
          },
          expenses: {
            total: expense_cash + expense_digital,
            cash: expense_cash,
            digital: expense_digital
          }
        }
      }
    }, status: :ok
  end
end
