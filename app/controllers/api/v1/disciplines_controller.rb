  # GET /disciplines
  # Returns a list of disciplines with their associated plan_disciplines and user_disciplines
  # GET /disciplines/:id
  # Returns a discipline with its associated plan_disciplines and user_disciplines
  # POST /disciplines
  # Creates a new discipline
  # PATCH/PUT /disciplines/:id
  # Updates a discipline's attributes
  # DELETE /disciplines/:id
  # Deletes a discipline
class Api::V1::DisciplinesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_discipline, only: %i[ show update destroy ]

  # GET /disciplines
  def index
    @disciplines = Discipline.includes(:plan_disciplines, :user_disciplines).all
    render json: { data: @disciplines.as_json(include: [:plan_disciplines, :user_disciplines]) }
  end

  # GET /disciplines/1
  def show
    discipline = Discipline.includes(:plan_disciplines, :user_disciplines).find(@discipline.id)
    render json: { data: discipline.as_json(include: [:plan_disciplines, :user_disciplines]) }
  end

  # POST /disciplines
  def create
    @discipline = Discipline.new(discipline_params)

    if @discipline.save
      render json: @discipline, status: :created
    else
      render json: @discipline.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /disciplines/1
  def update
    if @discipline.update(discipline_params)
      render json: @discipline
    else
      render json: @discipline.errors, status: :unprocessable_entity
    end
  end

  # DELETE /disciplines/1
  def destroy
    @discipline.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discipline
      @discipline = Discipline.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def discipline_params
      params.require(:discipline).permit(:name, :is_active)
    end
end
