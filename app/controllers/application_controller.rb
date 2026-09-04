# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Authenticable
  def options
    head :ok
  end
end
