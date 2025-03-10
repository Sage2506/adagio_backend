class Api::V1::PlanDisciplinesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_plan_discipline, only: %i[ show update destroy ]

  # GET /plan_disciplines
  def index
    @plan_disciplines = PlanDiscipline.all

    render json: @plan_disciplines
  end

  # GET /plan_disciplines/1
  def show
    render json: @plan_discipline
  end

  # POST /plan_disciplines
  def create
    @plan_discipline = PlanDiscipline.new(plan_discipline_params)

    if @plan_discipline.save
      render json: @plan_discipline, status: :created, location: @plan_discipline
    else
      render json: @plan_discipline.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plan_disciplines/1
  def update
    if @plan_discipline.update(plan_discipline_params)
      render json: @plan_discipline
    else
      render json: @plan_discipline.errors, status: :unprocessable_entity
    end
  end

  # DELETE /plan_disciplines/1
  def destroy
    @plan_discipline.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan_discipline
      @plan_discipline = PlanDiscipline.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def plan_discipline_params
      params.expect(plan_discipline: [ :plan_id, :discipline_id ])
    end
end
