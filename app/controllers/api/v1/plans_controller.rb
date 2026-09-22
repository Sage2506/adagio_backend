class Api::V1::PlansController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_plan, only: %i[ show update destroy ]

  # GET /plans
  def index
    @q = Plan.active.ransack(params[:q])
    current_limit = params[:limit].presence || Pagy::OPTIONS[:limit]
    pagy, records = pagy(:offset, @q.result(distinct: true), limit: current_limit)
    render json: {
      data: records,
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i },
      total: pagy.count
    }
  end

  # GET /plans/1
  def show
    render json: @plan.as_json(include: :disciplines)
  end

  # POST /plans
  def create
    @plan = Plan.new
    if save_with_disciplines
      render json: @plan.as_json(include: :disciplines), status: :created
    else
      render json: @plan.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plans/1
  def update
    if save_with_disciplines
      render json: @plan.as_json(include: :disciplines)
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
      @plan = Plan.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def plan_params
        params.require(:plan).permit(:name, :price, :subscription_duration, :tolerance_days, discipline_ids: [])
    end

    def save_with_disciplines
      attributes = plan_params
      discipline_ids = attributes.delete(:discipline_ids).to_a.reject(&:blank?).map(&:to_i).uniq
      if discipline_ids.empty?
        @plan.errors.add(:discipline_ids, "must include at least one discipline")
        return false
      end

      Plan.transaction do
        @plan.assign_attributes(attributes)
        @plan.save!
        @plan.discipline_ids = discipline_ids
      end
      true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => error
      @plan.errors.add(:base, error.message) if @plan.errors.empty?
      false
    end
end
