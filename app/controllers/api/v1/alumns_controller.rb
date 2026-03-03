class Api::V1::AlumnsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_alumn, only: %i[ show update destroy associate ]

  # GET /api/v1/alumns
  def index
    alumns = Alumn.active
    if params[:birth_month].present?
      month = params[:birth_month].to_i
      alumns = alumns.where('EXTRACT(MONTH FROM birth_date) = ?', month)
    end
    @q = alumns.ransack(params[:q])
    pagy, records = pagy(@q.result(distinct: true))
    render json: {
      data: records,
      links: pagy_jsonapi_links(pagy),
      pages: pagy.series.map { |item| item == :gap ? item : item.to_i }
    }
  end

  # GET /api/v1/alumns/1
  def show
    alumn = Alumn.includes(:guardians).find(@alumn.id)
    render json: {
      alumn: alumn.as_json(methods: %i[plan_id subscription_id]),
      guardians: alumn.guardians.order(created_at: :asc).as_json
    }
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
  # Asocia un guardian a un alumn
  def associate
    unless params[:guardian_id].present?
      return render json: { errors: ['guardian_id es requerido'] }, status: :unprocessable_entity
    end
    guardian = Guardian.find_by(id: params[:guardian_id])
    unless guardian
      return render json: { errors: ['Guardian no encontrado'] }, status: :not_found
    end
    if @alumn.guardians.exists?(guardian.id)
      return render json: { errors: ['Guardian ya asociado'] }, status: :unprocessable_entity
    end
    @alumn.guardians << guardian
    render json: { data: @alumn }, status: :ok
  end

  # DELETE /api/v1/alumns/1
  def destroy
    if @alumn.disable
      render json: { successful: true }, status: :ok
    else
      render json: { errors: @alumn.errors }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/alumns/birthdays_by_month?month=5
  def birthdays_by_month
    unless params[:month].present?
      return render json: { error: 'El parámetro month es requerido' }, status: :bad_request
    end

    month = params[:month].to_i
    unless month.between?(0, 11)
      return render json: { error: 'El mes debe estar entre 0 y 11' }, status: :bad_request
    end

    # Convertir de 0-11 a 1-12 para consulta SQL
    sql_month = month + 1
    alumns = Alumn.active.where('EXTRACT(MONTH FROM birth_date) = ?', sql_month)
                   .order(:birth_date)

    render json: alumns , status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alumn
      @alumn = Alumn.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def alumn_params
      params.require(:alumn).permit(:name, :last_name, :address, :phone_number, :email, :is_active, :birth_date, :guardian_id, :special_med_conditions, :is_guardian_required_for_leaving)
    end
end
