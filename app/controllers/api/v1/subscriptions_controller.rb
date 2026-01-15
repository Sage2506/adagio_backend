class Api::V1::SubscriptionsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_subscription, only: %i[ show update destroy rehabilitate ]
  # GET /subscriptions
  def index
    base_scope = subscriptions_base_scope.includes(:alumn, :plan)
    @q = if params[:full_name].present?
      base_scope.ransack(alumn_full_name_cont: params[:full_name].downcase)
    else
      base_scope.ransack(params[:q])
    end

    pagy, records = pagy(@q.result(distinct: true).order(status: :asc, due_date: :asc))

    render json: {
      data: records.as_json(include: [ :alumn, :plan ]),
      links: pagy_jsonapi_links(pagy),
      pages: pagy.series.map { |item| item == :gap ? item : item.to_i }
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
    @subscription.disable!
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params.require(:id))
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:plan_id, :alumn_id, :due_date, :status, :subscribed_at)
  end

  # Devuelve el scope base según el parámetro include_inactive
  def subscriptions_base_scope
    if params[:include_inactive].present? && params[:include_inactive].to_s == 'true'
      Subscription.all
    else
      Subscription.active
    end
  end
end
