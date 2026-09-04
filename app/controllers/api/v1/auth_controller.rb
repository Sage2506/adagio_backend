class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request!, only: [ :login, :logout ]
  # POST /auth/login
  def login
    auth_response = CognitoAuth.authenticate(params[:email], params[:password])
    # Handle AWS SDK Struct response
    if auth_response[:success]
      set_jwt_cookie(auth_response[:tokens][:id_token])
      render json: { success: true }
    else
      # Handle error cases (now checking for AWS error class)
      error_message = auth_response.is_a?(Aws::CognitoIdentityProvider::Errors::ServiceError) ?
                      auth_response.message :
                      auth_response[:error]
      render json: { error: error_message, code: auth_response[:code] }, status: :unauthorized
    end
  end

  # DELETE /auth/logout
  def logout
    cookies.delete(:jwt, **cookie_options)
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

  def cookie_options
    {
      httponly: true,
      secure: Rails.env.production?,
      # Frontend proxies /api/* through the same origin (see vercel.json),
      # so the request is always same-site — :lax is enough everywhere.
      same_site: :lax
    }
  end
end
