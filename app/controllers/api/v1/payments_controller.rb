class Api::V1::PaymentsController < ApplicationController
  include Pagy::Method
  before_action :set_payment, only: %i[ show update destroy ]
  before_action :validate_payable_params!, only: :create

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
    ordered_payments = @q.result(distinct: true).order(Arel.sql("paid_at DESC NULLS LAST"), created_at: :desc, id: :desc)
    pagy, records = pagy(:offset, ordered_payments)

    render json: {
      data: records,
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i }
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
      link_payment_to_payable! if params[:payable_type].present?
      deduct_mercadopago_commission! if @payment.card?
    end

    render json: @payment, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_invalid_record(e.record)
  rescue ActiveRecord::RecordNotFound
    render json: { errors: { payable_id: [ "Payable not found" ] } }, status: :not_found
  end

  # PATCH/PUT /payments/1
  def update
    if @payment.update(payment_params)
      render json: @payment
    else
      render_invalid_record(@payment)
    end
  end

  # DELETE /payments/1
  def destroy
    if @payment.destroy
      head :no_content
    else
      render_invalid_record(@payment)
    end
  end

  private
    # Links the just-created @payment to a subscription/order and applies its side effects.
    # Raises ActiveRecord::RecordInvalid so #create can render a consistent error response.
    def link_payment_to_payable!
      case params[:payable_type].downcase
      when "subscription"
        apply_subscription_payment!(Subscription.find(params[:payable_id]))
      when "order"
        apply_order_payment!(Order.find(params[:payable_id]))
      else
        @payment.errors.add(:base, "Unknown payable type: #{params[:payable_type]}")
        raise ActiveRecord::RecordInvalid, @payment
      end
    end

    # A subscription is considered settled once the accumulated paid_amount covers its effective price:
    # the due_date is then pushed forward and only the excess (if any) carries over as paid_amount.
    def apply_subscription_payment!(subscription)
      SubscriptionPayment.create!(payment: @payment, subscription: subscription)

      total_paid = params[:paid_amount].presence&.to_f || subscription.paid_amount + @payment.quantity
      attributes = { paid_amount: total_paid, last_payment_date: @payment.paid_at || Date.today }

      if total_paid >= subscription.effective_price
        attributes[:due_date] = next_due_date_for(subscription.due_date)
        attributes[:paid_amount] = total_paid - subscription.effective_price
      end

      subscription.update!(attributes)
    end

    def apply_order_payment!(order)
      order.register_payment!(@payment)
    end

    def deduct_mercadopago_commission!
      commission = (@payment.quantity * 0.0406).round(2)

      Expense.create!(
        amount: commission,
        category: :commission,
        payment_method: :card,
        date: @payment.paid_at&.to_date || Date.today,
        description: "Comisión MercadoPago (Ref: #{@payment.reference || 'N/A'})",
        user_email: @payment.user_email
      )
    end

    def valid_payable_type?(type)
      %w[subscription order].include?(type.to_s.downcase)
    end

    def validate_payable_params!
      errors = {}
      errors[:payable_type] = [ "must be 'subscription' or 'order'" ] unless valid_payable_type?(params[:payable_type])
      errors[:payable_id] = [ "is required" ] if params[:payable_id].blank?

      render json: { errors: errors }, status: :unprocessable_entity if errors.any?
    end

    def render_invalid_record(record)
      response = { errors: record.errors.to_hash(true) }
      response[:remaining_balance] = record.remaining_balance if record.is_a?(Order)

      render json: response, status: :unprocessable_entity
    end

    def next_due_date_for(due_date)
      due_date.day > 28 ? due_date.next_month.beginning_of_month : due_date + 1.month
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:alumn_id, :quantity, :created_at, :paid_at, :payment_method, :reference)
    end
end
