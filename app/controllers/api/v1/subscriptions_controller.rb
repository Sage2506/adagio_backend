class Api::V1::SubscriptionsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_subscription, only: %i[ show update destroy ]

  # GET /subscriptions
  def index
    @q = Subscription.includes(:alumn, :plan).ransack(params[:q])

    # Add full_name search if parameter exists
    if params[:full_name].present?
      @q = Subscription.includes(:alumn, :plan).ransack({
        alumn_full_name_cont: params[:full_name].downcase
      })
    end

    pagy, records = pagy(@q.result(distinct: true))

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
    @subscription.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def subscription_params
      params.expect(subscription: [ :plan_id, :alumn_id ])
    end
end
