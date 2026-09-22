class Api::V1::ExpensesController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_expense, only: :destroy

  def index
    @q = Expense.ransack(params[:q])
    pagy, records = pagy(:offset, @q.result(distinct: true))

    render json: {
      data: records,
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i },
      total: pagy.count
    }
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.user_email = @current_user_email

    if @expense.save
      render json: @expense, status: :created
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy!
  end

  private
    def set_expense
      @expense = Expense.find(params.require(:id))
    end

    def expense_params
      params.require(:expense).permit(:amount, :category, :payment_method, :date, :description)
    end
end
