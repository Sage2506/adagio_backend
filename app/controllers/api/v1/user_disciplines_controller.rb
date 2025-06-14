class Api::V1::UserDisciplinesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_user_discipline, only: %i[ show update destroy ]

  # GET /user_disciplines
  def index
    @user_disciplines = UserDiscipline.all

    render json: @user_disciplines
  end

  # GET /user_disciplines/1
  def show
    render json: @user_discipline
  end

  # POST /user_disciplines
  def create
    @user_discipline = UserDiscipline.new(user_discipline_params)

    if @user_discipline.save
      render json: @user_discipline, status: :created, location: @user_discipline
    else
      render json: @user_discipline.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_disciplines/1
  def update
    if @user_discipline.update(user_discipline_params)
      render json: @user_discipline
    else
      render json: @user_discipline.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_disciplines/1
  def destroy
    @user_discipline.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_discipline
      @user_discipline = UserDiscipline.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_discipline_params
      params.expect(user_discipline: [ :user_id, :discipline_id ])
    end
end
