require "test_helper"

class Api::V1::GuardiansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guardian = guardians(:one)
  end

  test "should get index" do
    get guardians_url, as: :json
    assert_response :success
  end

  test "should create guardian" do
    assert_difference("Api::V1::Guardian.count") do
      post guardians_url, params: { guardian: { address: @guardian.address, email: @guardian.email, is_active: @guardian.is_active, last_name: @guardian.last_name, name: @guardian.name, phone_number: @guardian.phone_number } }, as: :json
    end

    assert_response :created
  end

  test "should show guardian" do
    get guardian_url(@guardian), as: :json
    assert_response :success
  end

  test "should update guardian" do
    patch guardian_url(@guardian), params: { guardian: { address: @guardian.address, email: @guardian.email, is_active: @guardian.is_active, last_name: @guardian.last_name, name: @guardian.name, phone_number: @guardian.phone_number } }, as: :json
    assert_response :success
  end

  test "should destroy guardian" do
    assert_difference("Api::V1::Guardian.count", -1) do
      delete guardian_url(@guardian), as: :json
    end

    assert_response :no_content
  end
end
