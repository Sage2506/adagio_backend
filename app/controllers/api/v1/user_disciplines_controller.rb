  # GET /user_disciplines
  # Returns a list of user_disciplines with their associated user and discipline
  # GET /user_disciplines/:id
  # Returns a user_discipline with its associated user and discipline
  # POST /user_disciplines
  # Creates a new user_discipline
  # PATCH/PUT /user_disciplines/:id
  # Updates a user_discipline's attributes
  # DELETE /user_disciplines/:id
  # Deletes a user_discipline
class Api::V1::UserDisciplinesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_user_discipline, only: %i[ show update destroy ]

  # GET /user_disciplines
  def index
    @user_disciplines = UserDiscipline.includes(:user, :discipline).all
    render json: { data: @user_disciplines.as_json(include: [:user, :discipline]) }
  end

  # GET /user_disciplines/1
  def show
    user_discipline = UserDiscipline.includes(:user, :discipline).find(@user_discipline.id)
    render json: { data: user_discipline.as_json(include: [:user, :discipline]) }
  end

  # POST /user_disciplines
  def create
    @user_discipline = UserDiscipline.new(user_discipline_params)

    if @user_discipline.save
      render json: @user_discipline, status: :created
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
      @user_discipline = UserDiscipline.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_discipline_params
      params.require(:user_discipline).permit(:user_id, :discipline_id)
    end
end
