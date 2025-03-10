class Api::V1::SubscriptionPaymentsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_subscription_payment, only: %i[ show update destroy ]

  # GET /subscription_payments
  def index
    @subscription_payments = SubscriptionPayment.all

    render json: @subscription_payments
  end

  # GET /subscription_payments/1
  def show
    render json: @subscription_payment
  end

  # POST /subscription_payments
  def create
    @subscription_payment = SubscriptionPayment.new(subscription_payment_params)

    if @subscription_payment.save
      render json: @subscription_payment, status: :created, location: @subscription_payment
    else
      render json: @subscription_payment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscription_payments/1
  def update
    if @subscription_payment.update(subscription_payment_params)
      render json: @subscription_payment
    else
      render json: @subscription_payment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subscription_payments/1
  def destroy
    @subscription_payment.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription_payment
      @subscription_payment = SubscriptionPayment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def subscription_payment_params
      params.expect(subscription_payment: [ :subcription_id, :payment_id ])
    end
end
