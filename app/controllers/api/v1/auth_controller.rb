class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request!, only: [ :login, :logout, :refresh ]

  # POST /auth/login
  def login
    email = params.dig(:user, :email) || params[:email]
    password = params.dig(:user, :password) || params[:password]
    remember_me = parse_boolean(params.dig(:user, :remember_me) || params[:remember_me])

    auth_response = CognitoAuth.authenticate(email, password)

    if auth_response[:success]
      set_jwt_cookie(auth_response[:tokens][:id_token])
      set_refresh_token_cookie(auth_response[:tokens][:refresh_token], remember_me: remember_me)
      render json: { success: true }
    else
      error_message = auth_response.is_a?(Aws::CognitoIdentityProvider::Errors::ServiceError) ?
                      auth_response.message :
                      auth_response[:error]
      render json: { error: error_message, code: auth_response[:code] }, status: :unauthorized
    end
  end

  # POST /auth/refresh
  def refresh
    refresh_token = cookies[:refresh_token]
    return render json: { error: "Refresh token missing" }, status: :unauthorized if refresh_token.blank?

    auth_response = CognitoAuth.refresh(refresh_token)

    if auth_response[:success]
      set_jwt_cookie(auth_response[:tokens][:id_token])
      set_refresh_token_cookie(auth_response[:tokens][:refresh_token])
      render json: { success: true }
    else
      cookies.delete(:jwt, **cookie_options)
      cookies.delete(:refresh_token, **cookie_options)
      render json: { error: auth_response[:error] || "Session expired" }, status: :unauthorized
    end
  end

  # DELETE /auth/logout
  def logout
    cookies.delete(:jwt, **cookie_options)
    cookies.delete(:refresh_token, **cookie_options)
    head :no_content
  end

  # GET /auth/me
  def me
    render json: { email: @current_user_email }
  end

  private

  def set_jwt_cookie(token)
    cookies[:jwt] = { value: token, expires: 1.hour.from_now, **cookie_options }
  end

  def set_refresh_token_cookie(token, remember_me: false)
    expires_at = remember_me ? 30.days.from_now : 1.hour.from_now
    cookies[:refresh_token] = { value: token, expires: expires_at, **cookie_options }
  end

  def parse_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def cookie_options
    {
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      path: "/"
    }
  end
end
