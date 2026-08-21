# GET /plan_disciplines
# Returns a list of plan_disciplines with their associated plan and discipline
# GET /plan_disciplines/:id
# Returns a plan_discipline with its associated plan and discipline
# POST /plan_disciplines
# Creates a new plan_discipline
# PATCH/PUT /plan_disciplines/:id
# Updates a plan_discipline's attributes
# DELETE /plan_disciplines/:id
# Deletes a plan_discipline
class Api::V1::PlanDisciplinesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_plan_discipline, only: %i[ show update destroy ]

  # GET /plan_disciplines
  def index
    @plan_disciplines = PlanDiscipline.includes(:plan, :discipline).all
    render json: { data: @plan_disciplines.as_json(include: [ :plan, :discipline ]) }
  end

  # GET /plan_disciplines/1
  def show
    plan_discipline = PlanDiscipline.includes(:plan, :discipline).find(@plan_discipline.id)
    render json: { data: plan_discipline.as_json(include: [ :plan, :discipline ]) }
  end

  # POST /plan_disciplines
  def create
    @plan_discipline = PlanDiscipline.new(plan_discipline_params)

    if @plan_discipline.save
      render json: @plan_discipline, status: :created
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
      @plan_discipline = PlanDiscipline.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def plan_discipline_params
      params.require(:plan_discipline).permit(:plan_id, :discipline_id)
    end
end
