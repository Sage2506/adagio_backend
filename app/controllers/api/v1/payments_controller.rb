class Api::V1::PaymentsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_payment, only: %i[ show update destroy ]

  # GET /payments
  def index
    @payments = Payment.all

    render json: @payments
  end

  # GET /payments/1
  def show
    render json: @payment
  end

  # POST /payments
  def create
    @payment = Payment.new(payment_params)
    @payment.user_email = @current_user_email
    ActiveRecord::Base.transaction do
      @payment.save!
      if params[:payable_type].present?
        unless link_payment_to_object # Only proceed if linking succeeds
          raise ActiveRecord::RecordInvalid.new(@payment)
        end
      end
      render json: @payment, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def link_payment_to_object
    case params[:payable_type].downcase
    when "subscription"
      subscription = Subscription.find(params[:payable_id])
      new_paid_amount = subscription.paid_amount + @payment.quantity
      SubscriptionPayment.create!(
        payment: @payment,
        subscription_id: params[:payable_id]
      )
      subscription.update!(
        paid_amount: new_paid_amount
      )

      if new_paid_amount >= subscription.plan.price
        subscription.update!(
          last_payment_date: Date.today,
          due_date: subscription.due_date + subscription.plan.subscription_duration_days,
          paid_amount: 0.0
        )
      end
      true
    when "order"
      order = Order.find(params[:payable_id])
        OrderPayment.create(payment: @payment, order: order)
        order.paid_amount = order.paid_amount + @payment.quantity
        if order.paid_amount == order.total
          order.status = 2
        else
          order.status = 1
        end
        order.save
        true
    else
      @payment.errors.add(:base, "Unknown payable type: #{params[:payable_type]}")
      false
    end
  end

  # PATCH/PUT /payments/1
  def update
    if @payment.update(payment_params)
      render json: @payment
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /payments/1
  def destroy
    @payment.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:alumn_id, :quantity, :created_at)
    end
end
