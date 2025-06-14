module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token = header&.split("Bearer ")&.last
    decoded = CognitoAuth.verify_token(token)
    if decoded[0][:error]
      render json: { error: decoded[:error] }, status: :unauthorized
    else
      @current_user_email = decoded[0]["email"]
    end
  end
end
