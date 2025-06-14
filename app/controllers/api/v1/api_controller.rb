class Api::V1::ApiController < ApplicationController
  include Authenticable

  def profile
    render json: { email: @current_user_email }
  end
end
