# GET /assistances
# Returns a list of assistances with their associated lesson and alumn
# GET /assistances/:id
# Returns an assistance with its associated lesson and alumn
# POST /assistances
# Creates a new assistance
# PATCH/PUT /assistances/:id
# Updates an assistance's attributes
# DELETE /assistances/:id
# Deletes an assistance
class Api::V1::AssistancesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_assistance, only: %i[ show update destroy ]

  # GET /assistances
  def index
    @assistances = Assistance.includes(:lesson, :alumn).all
    render json: { data: @assistances.as_json(include: [ :lesson, :alumn ]) }
  end

  # GET /assistances/1
  def show
    assistance = Assistance.includes(:lesson, :alumn).find(@assistance.id)
    render json: { data: assistance.as_json(include: [ :lesson, :alumn ]) }
  end

  # POST /assistances
  def create
    @assistance = Assistance.new(assistance_params)

    if @assistance.save
      render json: @assistance, status: :created
    else
      render json: @assistance.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /assistances/1
  def update
    if @assistance.update(assistance_params)
      render json: @assistance
    else
      render json: @assistance.errors, status: :unprocessable_entity
    end
  end

  # DELETE /assistances/1
  def destroy
    @assistance.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assistance
      @assistance = Assistance.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def assistance_params
      params.require(:assistance).permit(:lesson_id, :alumn_id)
    end
end
