class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request!
  # POST /auth/login
  def login
        auth_response = CognitoAuth.authenticate(params[:email], params[:password])
    # Handle AWS SDK Struct response
    if auth_response[:success]
      render json: auth_response[:tokens]
    else
      # Handle error cases (now checking for AWS error class)
      error_message = auth_response.is_a?(Aws::CognitoIdentityProvider::Errors::ServiceError) ?
                      auth_response.message :
                      auth_response[:error]
      render json: { error: error_message, code: auth_response[:code] }, status: :unauthorized
    end
  end

  # Protected endpoint (example)
  def protected
    token = request.headers["Authorization"]&.split("Bearer ")&.last
    begin
      decoded = CognitoService.new.verify_token(token)
      render json: { message: "Hello, #{decoded[0]['email']}!" }
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token: #{e.message}" }, status: 401
    end
  end
end
