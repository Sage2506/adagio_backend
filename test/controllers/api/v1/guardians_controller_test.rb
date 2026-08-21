require "test_helper"

class Api::V1::GuardiansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guardian = guardians(:one)
  end

  test "should get index" do
    get api_v1_guardians_url, as: :json
    assert_response :success
  end

  test "should create guardian" do
    assert_difference("Guardian.count") do
      post api_v1_guardians_url, params: { guardian: { address: @guardian.address, email: @guardian.email, is_active: @guardian.is_active, last_name: @guardian.last_name, name: @guardian.name, phone_number: @guardian.phone_number } }, as: :json
    end

    assert_response :created
  end

  test "should show guardian" do
    get api_v1_guardian_url(@guardian), as: :json
    assert_response :success
  end

  test "should update guardian" do
    patch api_v1_guardian_url(@guardian), params: { guardian: { address: @guardian.address, email: @guardian.email, is_active: @guardian.is_active, last_name: @guardian.last_name, name: @guardian.name, phone_number: @guardian.phone_number } }, as: :json
    assert_response :success
  end

  test "should destroy guardian" do
    delete api_v1_guardian_url(@guardian), as: :json

    assert_response :success
    assert_not @guardian.reload.is_active
  end
end
