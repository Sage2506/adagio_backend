class Api::V1::AdditionalIncomesController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_additional_income, only: :destroy

  def index
    @q = AdditionalIncome.ransack(params[:q])
    pagy, records = pagy(:offset, @q.result(distinct: true).reorder(created_at: :desc))

    render json: {
      data: records,
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i },
      total: pagy.count
    }
  end

  def create
    @additional_income = AdditionalIncome.new(additional_income_params)
    @additional_income.user_email = @current_user_email

    ActiveRecord::Base.transaction do
      @additional_income.save!
      deduct_mercadopago_commission! if @additional_income.card?
    end

    render json: @additional_income, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end

  def destroy
    @additional_income.destroy!
  end

  private
    def deduct_mercadopago_commission!
      commission = (@additional_income.amount * 0.0406).round(2)

      Expense.create!(
        amount: commission,
        category: :commission,
        payment_method: :card,
        date: @additional_income.date,
        description: "Comisión MercadoPago (Ingreso adicional)",
        user_email: @additional_income.user_email
      )
    end

    def set_additional_income
      @additional_income = AdditionalIncome.find(params.require(:id))
    end

    def additional_income_params
      params.require(:additional_income).permit(:amount, :category, :payment_method, :date, :description)
    end
end
