class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request!, only: %i[ create update destroy]
  before_action :set_user, only: [ :show, :destroy ]

  # GET /users
  def index
    @users = User.all
    render json: @users, status: :ok
  end

  # GET /users/{email}

  def show
    render json: @user, status: :ok
  end

  # POST /users/{email}
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  # PUT /users/{email}
  def update
    unless @user.update(user_params)
      render json: { errors: @user.errors.full_messages },
        status: :unprocessable_entity
    end
  end

  # DELETE /users/{email}
  def destroy
    @user.is_active = false
    @user.save
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :name, :last_name, :password)
    end
end
