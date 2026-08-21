# GET /api/v1/guardians
# Returns a list of guardians with their associated alumns
# GET /api/v1/guardians/:id
# Returns a guardian and its associated alumns
# POST /api/v1/guardians
# Creates a new guardian. If alumn_id is present, associates the guardian with the alumn
# PATCH/PUT /api/v1/guardians/:id
# Updates a guardian's attributes
# PATCH/PUT /api/v1/guardians/:id/associate
# Associates an alumn to the guardian if alumn_id is present
# DELETE /api/v1/guardians/:id
# Disables a guardian (soft delete)
class Api::V1::GuardiansController < ApplicationController
  before_action :authenticate_request!
  before_action :set_guardian, only: %i[ show update destroy associate ]
  # GET /api/v1/guardians
  def index
    query = params[:query].to_s.strip
    @guardians = Guardian.where(is_active: true)
    if query.length >= 3
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query.downcase)}%"
      @guardians = @guardians
                   .where("LOWER(CONCAT_WS(' ', name, last_name)) LIKE ?", pattern)
                   .order(:name, :last_name)
                   .limit(10)
    else
      @guardians = @guardians.none
    end
    render json: { data: @guardians }
  end

  # GET /api/v1/guardians/1
  def show
    guardian = Guardian.includes(:alumns).find(@guardian.id)
    render json: { data: guardian.as_json(include: :alumns) }
  end

  # POST /api/v1/guardians
  def create
    @guardian = Guardian.new(guardian_params.except(:alumn_id))

    if @guardian.save
      if params[:alumn_id].present?
        @guardian.alumns << Alumn.find(params[:alumn_id])
      end
      render json: @guardian, status: :created
    else
      render json: @guardian.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/guardians/1
  def update
    if @guardian.update(guardian_params.except(:alumn_id))
      render json: @guardian
    else
      render json: @guardian.errors, status: :unprocessable_entity
    end
  end
  # PATH/put /api/v1/guardians/1/associate
  def associate
    if params[:alumn_id].present?
        @guardian.alumns << Alumn.find(params[:alumn_id])
    end
    render json: @guardian, status: :ok
  end

  # DELETE /api/v1/guardians/1
  def destroy
    @guardian.is_active = false
    @guardian.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guardian
      @guardian = Guardian.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def guardian_params
      params.require(:guardian).permit(:name, :last_name, :phone_number, :email, :is_active, :alumn_id)
    end
end
