class Api::V1::AlumnGuardiansController < ApplicationController
  before_action :authenticate_request!
  before_action :set_alumn_guardian, only: %i[ show update destroy ]

  # GET /api/v1/alumn_guardians
  def index
    @alumn_guardians = AlumnGuardian.all

    render json: @alumn_guardians
  end

  # GET /api/v1/alumn_guardians/1
  def show
    render json: @alumn_guardian
  end

  # POST /api/v1/alumn_guardians
  def create
    @alumn_guardian = AlumnGuardian.new(alumn_guardian_params)

    if @alumn_guardian.save
      render json: @alumn_guardian, status: :created, location: @alumn_guardian
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
  def destroy
    @alumn_guardian.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alumn_guardian
      @alumn_guardian = AlumnGuardian.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def alumn_guardian_params
      params.expect(alumn_guardian: [ :alumn_id, :guardian_id ])
    end
end
