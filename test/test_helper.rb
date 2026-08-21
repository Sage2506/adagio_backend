ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Default auth stub for API integration tests, so scaffolded requests don't
# need to know about Cognito. Tests needing a different identity can still
# override with `CognitoAuth.stub :verify_token, [...] do ... end`.
class ActionDispatch::IntegrationTest
  setup do
    CognitoAuth.define_singleton_method(:verify_token) do |_token|
      [ { "email" => "test@example.com" } ]
    end
  end
end
