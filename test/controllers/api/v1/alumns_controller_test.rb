require "test_helper"

class Api::V1::AlumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn = alumns(:one)
  end

  test "should get index" do
    get alumns_url, as: :json
    assert_response :success
  end

  test "should create alumn" do
    assert_difference("Api::V1::Alumn.count") do
      post alumns_url, params: { alumn: { address: @alumn.address, email: @alumn.email, is_active: @alumn.is_active, last_name: @alumn.last_name, name: @alumn.name, phone_number: @alumn.phone_number } }, as: :json
    end

    assert_response :created
  end

  test "should show alumn" do
    get alumn_url(@alumn), as: :json
    assert_response :success
  end

  test "should update alumn" do
    patch alumn_url(@alumn), params: { alumn: { address: @alumn.address, email: @alumn.email, is_active: @alumn.is_active, last_name: @alumn.last_name, name: @alumn.name, phone_number: @alumn.phone_number } }, as: :json
    assert_response :success
  end

  test "should destroy alumn" do
    assert_difference("Api::V1::Alumn.count", -1) do
      delete alumn_url(@alumn), as: :json
    end

    assert_response :no_content
  end
end
