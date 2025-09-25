class Api::V1::PaymentsController < ApplicationController
  include Pagy::Backend
  before_action :set_payment, only: %i[ show update destroy ]

  # GET /payments
  def index
    @payments = []
    if params[:payable_type].present?

      unless valid_payable_type?(params[:payable_type])
        return render json: { error: "Invalid payable_type. Must be 'subscription' or 'order'" }, status: :unprocessable_entity
      end

      unless params[:payable_id].present?
        return render json: { error: "payable_id is required when payable_type is provided" }, status: :unprocessable_entity
      end

      begin
        case params[:payable_type].downcase
        when "subscription"
          @payments = Subscription.find(params[:payable_id]).payments
        when "order"
          @payments = Order.find(params[:payable_id]).payments
        end
      rescue ActiveRecord::RecordNotFound
        return render json: { error: "#{params[:payable_type].capitalize} not found" }, status: :not_found
      end
    else
      @payments = Payment.all
    end
    # Apply ransack search and pagination
    @q = @payments.ransack(params[:q])
    pagy, records = pagy(@q.result(distinct: true))

    render json: {
      data: records,
      links: pagy_jsonapi_links(pagy),
      pages: pagy.series.map { |item| item == :gap ? item : item.to_i }
    }
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
          last_payment_date: @payment.paid_at || Date.today,
          due_date: params[:due_date] || subscription.due_date + subscription.plan.subscription_duration,
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
    def valid_payable_type?(type)
      %w[subscription order].include?(type.downcase)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:alumn_id, :quantity, :created_at, :paid_at)
    end
end
