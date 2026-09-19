class Api::V1::SubscriptionsController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_subscription, only: %i[ show update destroy ]
  # GET /subscriptions
  def index
    base_scope = subscriptions_base_scope.includes(:alumn, :plan)
    @q = if params[:full_name].present?
      base_scope.ransack(alumn_full_name_cont: params[:full_name].downcase)
    else
      base_scope.ransack(params[:q])
    end

    pagy, records = pagy(:offset, @q.result(distinct: true).order(status: :asc, due_date: :asc))

    render json: {
      data: records.as_json(include: [ :alumn, :plan ]),
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i },
      total: pagy.count
    }
  end

  # GET /subscriptions/1
  def show
    render json: @subscription
  end

  # POST /subscriptions
  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      render json: @subscription, status: :created
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscriptions/1
  def update
    if @subscription.update(subscription_params)
      render json: @subscription
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subscriptions/1
  def destroy
    @subscription.disable
  end

  def add_credit
    @subscription = Subscription.find(params[:id])
    credit_amount = params[:amount].to_f

    if credit_amount <= 0
      return render json: { error: "El monto del crédito debe ser mayor a 0" }, status: :unprocessable_entity
    end

    # Sumamos el saldo promocional al saldo a favor existente
    new_paid_amount = @subscription.paid_amount + credit_amount
    attributes = { paid_amount: new_paid_amount }

    if new_paid_amount >= @subscription.effective_price
      attributes[:due_date] = next_due_date_for(@subscription.due_date)
      attributes[:paid_amount] = new_paid_amount - @subscription.effective_price
    end

    if @subscription.update(attributes)
      render json: {
        message: "Crédito de $#{credit_amount} aplicado promoción",
        subscription: @subscription
      }, status: :ok
    else
      render json: { errors: @subscription.errors.to_hash(true) }, status: :unprocessable_entity
    end
  end

  def monthly_income
    total = Subscription.active.includes(:plan).sum do |subscription|
      subscription.effective_price.to_f
    end

    render json: { total: total.to_f }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params.require(:id))
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:plan_id, :alumn_id, :due_date, :status, :subscribed_at, :custom_price)
  end

  # Devuelve el scope base según el parámetro include_inactive
  def subscriptions_base_scope
    if params[:include_inactive].present? && params[:include_inactive].to_s == "true"
      Subscription.all
    else
      Subscription.active
    end
  end

  def next_due_date_for(due_date)
    due_date.day > 28 ? due_date.next_month.beginning_of_month : due_date + 1.month
  end
end
