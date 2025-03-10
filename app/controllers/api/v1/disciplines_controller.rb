class Api::V1::DisciplinesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_discipline, only: %i[ show update destroy ]

  # GET /disciplines
  def index
    @disciplines = Discipline.all

    render json: @disciplines
  end

  # GET /disciplines/1
  def show
    render json: @discipline
  end

  # POST /disciplines
  def create
    @discipline = Discipline.new(discipline_params)

    if @discipline.save
      render json: @discipline, status: :created, location: @discipline
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
      @discipline = Discipline.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def discipline_params
      params.expect(discipline: [ :name, :is_active ])
    end
end
