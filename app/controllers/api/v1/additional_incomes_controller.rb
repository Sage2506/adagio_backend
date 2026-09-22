class Api::V1::AdditionalIncomesController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_additional_income, only: :destroy

  def index
    @q = AdditionalIncome.ransack(params[:q])
    pagy, records = pagy(:offset, @q.result(distinct: true))

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

    if @additional_income.save
      render json: @additional_income, status: :created
    else
      render json: @additional_income.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @additional_income.destroy!
  end

  private
    def set_additional_income
      @additional_income = AdditionalIncome.find(params.require(:id))
    end

    def additional_income_params
      params.require(:additional_income).permit(:amount, :category, :payment_method, :date, :description)
    end
end
