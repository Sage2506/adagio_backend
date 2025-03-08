require "test_helper"

class Api::V1::AlumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_alumn = api_v1_alumns(:one)
  end

  test "should get index" do
    get api_v1_alumns_url, as: :json
    assert_response :success
  end

  test "should create api_v1_alumn" do
    assert_difference("Api::V1::Alumn.count") do
      post api_v1_alumns_url, params: { api_v1_alumn: { address: @api_v1_alumn.address, email: @api_v1_alumn.email, is_active: @api_v1_alumn.is_active, last_name: @api_v1_alumn.last_name, name: @api_v1_alumn.name, phone_number: @api_v1_alumn.phone_number } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_alumn" do
    get api_v1_alumn_url(@api_v1_alumn), as: :json
    assert_response :success
  end

  test "should update api_v1_alumn" do
    patch api_v1_alumn_url(@api_v1_alumn), params: { api_v1_alumn: { address: @api_v1_alumn.address, email: @api_v1_alumn.email, is_active: @api_v1_alumn.is_active, last_name: @api_v1_alumn.last_name, name: @api_v1_alumn.name, phone_number: @api_v1_alumn.phone_number } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_alumn" do
    assert_difference("Api::V1::Alumn.count", -1) do
      delete api_v1_alumn_url(@api_v1_alumn), as: :json
    end

    assert_response :no_content
  end
end
