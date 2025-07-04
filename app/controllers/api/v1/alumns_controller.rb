class Api::V1::AlumnsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_alumn, only: %i[ show update destroy ]

  # GET /api/v1/alumns
  def index
    @q = Alumn.ransack(params[:q])
    pagy, records = pagy(@q.result(distinct: true))
    render json: { data: records, links: pagy_jsonapi_links(pagy), pages: pagy.series.map { |item| item == :gap ? item : item.to_i } }
  end

  # GET /api/v1/alumns/1
  def show
    render json: @alumn.as_json(include: :guardians, methods: %i[plan_id subscription_id])
  end

  # POST /api/v1/alumns
  def create
    @alumn = Alumn.new(alumn_params.except(:guardian_id))
    if @alumn.save
      render json: @alumn, status: :created
    else
      render json: @alumn.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/alumns/1
  def update
    if @alumn.update(alumn_params.except(:guardian_id))
      render json: @alumn
    else
      render json: @alumn.errors, status: :unprocessable_entity
    end
  end

  # PATH/put /api/v1/guardians/1/associate
  def associate
    if params[:guardian_id].present?
        @alumn.guardians << Guardian.find(params[:guardian_id])
    end
    render json: @alumn, status: :ok
  end

  # DELETE /api/v1/alumns/1
  def destroy
    @alumn.is_active = false
    @alumn.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alumn
      @alumn = Alumn.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def alumn_params
      params.expect(alumn: [ :name, :last_name, :address, :phone_number, :email, :is_active, :birth_date, :guardian_id, :special_med_conditions, :is_guardian_required_for_leaving ])
    end
end
