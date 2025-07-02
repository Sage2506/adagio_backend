class Api::V1::GuardiansController < ApplicationController
  before_action :authenticate_request!
  before_action :set_guardian, only: %i[ show update destroy associate ]
  # GET /api/v1/guardians
  def index
    @guardians = Guardian.all

    render json: @guardians
  end

  # GET /api/v1/guardians/1
  def show
    render json: @guardian
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
      @guardian = Guardian.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def guardian_params
      params.expect(guardian: [ :name, :last_name,  :phone_number, :email, :is_active, :alumn_id ])
    end
end
