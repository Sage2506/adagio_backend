class Api::V1::PlansController < ApplicationController
  before_action :authenticate_request!
  before_action :set_plan, only: %i[ show update destroy ]

  # GET /plans
  def index
    @plans = Plan.all

    render json: @plans
  end

  # GET /plans/1
  def show
    render json: @plan
  end

  # POST /plans
  def create
    @plan = Plan.new(plan_params)

    if @plan.save
      render json: @plan, status: :created, location: @plan
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
    @plan.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def plan_params
      params.expect(plan: [ :name, :price, :subscription_duration, :tolerance_days, :is_active ])
    end
end
