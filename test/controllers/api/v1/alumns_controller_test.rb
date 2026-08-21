require "test_helper"

class Api::V1::AlumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn = alumns(:one)
  end

  test "should get index" do
    get api_v1_alumns_url, as: :json
    assert_response :success
  end

  test "should create alumn" do
    assert_difference("Alumn.count") do
      post api_v1_alumns_url, params: { alumn: { address: @alumn.address, email: @alumn.email, is_active: @alumn.is_active, last_name: @alumn.last_name, name: @alumn.name, phone_number: @alumn.phone_number } }, as: :json
    end

    assert_response :created
  end

  test "should show alumn" do
    get api_v1_alumn_url(@alumn), as: :json
    assert_response :success
  end

  test "should update alumn" do
    patch api_v1_alumn_url(@alumn), params: { alumn: { address: @alumn.address, email: @alumn.email, is_active: @alumn.is_active, last_name: @alumn.last_name, name: @alumn.name, phone_number: @alumn.phone_number } }, as: :json
    assert_response :success
  end

  test "should destroy alumn" do
    delete api_v1_alumn_url(@alumn), as: :json

    assert_response :success
    assert_not @alumn.reload.is_active
  end
end
