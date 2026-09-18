# app/services/cognito_auth.rb
require "aws-sdk-cognitoidentityprovider"
require "jwt"
class CognitoAuth
  def self.calculate_secret_hash(email)
    client_id = Rails.application.credentials.aws[:cognito_client_id]
    client_secret = Rails.application.credentials.aws[:cognito_client_secret]
    # This is the EXACT format Cognito expects:
    OpenSSL::HMAC.base64digest(
      OpenSSL::Digest.new("sha256"),
      client_secret,
      "#{email}#{client_id}"
    )
  end

  def self.authenticate(email, password)
    client = Aws::CognitoIdentityProvider::Client.new(
      region: Rails.application.credentials.aws[:region],
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key]
    )

    begin
      response = client.initiate_auth(
        auth_flow: "USER_PASSWORD_AUTH",
        client_id: Rails.application.credentials.aws[:cognito_client_id],
        auth_parameters: {
          "USERNAME" => email,
          "PASSWORD" => password,
          "SECRET_HASH" => calculate_secret_hash(email)
        }
      )

      if response.challenge_name
        handle_challenge(response, email)
      elsif response.authentication_result
        {
          success: true,
          tokens: {
            id_token: response.authentication_result.id_token,
            access_token: response.authentication_result.access_token,
            refresh_token: response.authentication_result.refresh_token
          }
        }
      end

    rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
      { error: "Invalid email or password", code: "NotAuthorized" }
    rescue Aws::CognitoIdentityProvider::Errors::UserNotConfirmedException
      { error: "Email not verified", code: "UserNotConfirmed" }
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      { error: e.message, code: e.code }
    end
  end

  def self.refresh(refresh_token)
    client = Aws::CognitoIdentityProvider::Client.new(
      region: Rails.application.credentials.aws[:region],
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key]
    )

    begin
      response = client.initiate_auth(
        auth_flow: "REFRESH_TOKEN_AUTH",
        client_id: Rails.application.credentials.aws[:cognito_client_id],
        auth_parameters: {
          "REFRESH_TOKEN" => refresh_token
        }
      )

      if response.authentication_result
        {
          success: true,
          tokens: {
            id_token: response.authentication_result.id_token,
            access_token: response.authentication_result.access_token,
            refresh_token: response.authentication_result.refresh_token || refresh_token
          }
        }
      else
        { error: "Unable to refresh token", code: "RefreshFailed" }
      end
    rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
      { error: "Refresh token expired or invalid", code: "NotAuthorized" }
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      { error: e.message, code: e.code }
    end
  end

  # Verify JWT token from frontend
  def self.verify_token(token)
    jwks_url = "https://cognito-idp.#{Rails.application.credentials.aws[:region]}.amazonaws.com/#{Rails.application.credentials.aws[:cognito_user_pool_id]}/.well-known/jwks.json"
    jwks = HTTParty.get(jwks_url).parsed_response
    JWT.decode(token, nil, true, algorithms: [ "RS256" ], jwks: jwks)
  end

  private

  def self.handle_challenge(response, email)
    case response.challenge_name
    when "NEW_PASSWORD_REQUIRED"
      {
        error: "Password change required",
        code: "ForceChangePassword",
        session: response.session,  # Required for password change
        email: email
      }
    else
      { error: "Unhandled challenge: #{response.challenge_name}", code: response.challenge_name }
    end
  end
end
