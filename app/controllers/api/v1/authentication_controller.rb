class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request!
  # POST /auth/login
  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password])
      auth_token = JsonWebToken.encode({ user_id: user.id })
      render json: { auth_token: }, status: :ok
    else
      render json: { error: "Invalid username / password" }, status: :unauthorized
    end
  end
end
