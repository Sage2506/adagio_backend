  # GET /api/v1/alumn_guardians
  # Returns a list of alumn_guardians with their associated alumn and guardian
  # GET /api/v1/alumn_guardians/:id
  # Returns an alumn_guardian with its associated alumn and guardian
  # POST /api/v1/alumn_guardians
  # Creates a new alumn_guardian
  # PATCH/PUT /api/v1/alumn_guardians/:id
  # Updates an alumn_guardian's attributes
  # DELETE /api/v1/alumn_guardians/:id
  # Deletes an alumn_guardian
class Api::V1::AlumnGuardiansController < ApplicationController
  before_action :authenticate_request!
  before_action :set_alumn_guardian, only: %i[ show update destroy ]

  # GET /api/v1/alumn_guardians
  def index
    @alumn_guardians = AlumnGuardian.includes(:alumn, :guardian).all
    render json: { data: @alumn_guardians.as_json(include: [:alumn, :guardian]) }
  end

  # GET /api/v1/alumn_guardians/1
  def show
    alumn_guardian = AlumnGuardian.includes(:alumn, :guardian).find(@alumn_guardian.id)
    render json: { data: alumn_guardian.as_json(include: [:alumn, :guardian]) }
  end

  # POST /api/v1/alumn_guardians
  # POST /api/v1/alumn_guardians
  # Assigns a guardian to an alumn, avoiding duplicates
  def create
    alumn_id = alumn_guardian_params[:alumn_id]
    guardian_id = alumn_guardian_params[:guardian_id]
    if AlumnGuardian.exists?(alumn_id: alumn_id, guardian_id: guardian_id)
      render json: { errors: ["This guardian is already assigned to this alumn."] }, status: :unprocessable_entity
      return
    end
    @alumn_guardian = AlumnGuardian.new(alumn_guardian_params)
    if @alumn_guardian.save
      render json: @alumn_guardian, status: :created
    else
      render json: @alumn_guardian.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/alumn_guardians/1
  def update
    if @alumn_guardian.update(alumn_guardian_params)
      render json: @alumn_guardian
    else
      render json: @alumn_guardian.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/alumn_guardians/1
  # DELETE /api/v1/alumn_guardians/:id
  # Unassigns a guardian from an alumn
  def destroy
    if @alumn_guardian.destroy
      render json: { message: "Guardian unassigned from alumn successfully." }, status: :ok
    else
      render json: { errors: @alumn_guardian.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alumn_guardian
      @alumn_guardian = AlumnGuardian.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def alumn_guardian_params
      params.require(:alumn_guardian).permit(:alumn_id, :guardian_id)
    end
end
