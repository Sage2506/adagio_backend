class Api::V1::PlansController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_plan, only: %i[ show update destroy ]

  # GET /plans
  def index
    @q = Plan.ransack(params[:q])
    pagy, records = pagy(@q.result(distinct: true))
    render json: { data: records, links: pagy_jsonapi_links(pagy), pages: pagy.series.map { |item| item == :gap ? item : item.to_i } }
  end

  # GET /plans/1
  def show
    render json: @plan
  end

  # POST /plans
  def create
    @plan = Plan.new(plan_params)
    if @plan.save
      render json: @plan, status: :created
    else
      render json: @plan.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plans/1
  def update
    if @plan.update(plan_params)
      render json: @plan
    else
      render json: @plan.errors, status: :unprocessable_entity
    end
  end

  # DELETE /plans/1
  def destroy
    @plan.is_active = false
    if @plan.save
      render json: { successfull: true }, status: :ok
    else
      render json: @plan.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def plan_params
      params.require(:plan).permit(:name, :price, :subscription_duration, :tolerance_days)
    end
end
