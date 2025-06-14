module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token = header&.split("Bearer ")&.last
    begin
    decoded = CognitoAuth.verify_token(token)
    @current_user_email = decoded[0]["email"]
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token: #{e.message}" }, status: 401
    end
  end
end
