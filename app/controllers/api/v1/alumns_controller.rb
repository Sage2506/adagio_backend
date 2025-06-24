class Api::V1::AlumnsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_alumn, only: %i[ show update destroy ]

  # GET /api/v1/alumns
  def index
    @q = Alumn.ransack(params[:q])
    pagy, records = pagy(@q.result(distinct: true))
    render json: { data: records, links: pagy_jsonapi_links(pagy) }
  end

  # GET /api/v1/alumns/1
  def show
    render json: @alumn
  end

  # POST /api/v1/alumns
  def create
    @alumn = Alumn.new(alumn_params)

    if @alumn.save
      render json: @alumn, status: :created, location: @alumn
    else
      render json: @alumn.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/alumns/1
  def update
    if @alumn.update(alumn_params)
      render json: @alumn
    else
      render json: @alumn.errors, status: :unprocessable_entity
    end
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
      params.expect(alumn: [ :name, :last_name, :address, :phone_number, :email, :is_active ])
    end
end
