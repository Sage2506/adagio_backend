require "test_helper"

class Api::V1::AlumnGuardiansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn_guardian = alumn_guardians(:one)
  end

  test "should get index" do
    get api_v1_alumn_guardians_url, as: :json
    assert_response :success
  end

  test "should create alumn_guardian" do
    assert_difference("AlumnGuardian.count") do
      post api_v1_alumn_guardians_url, params: { alumn_guardian: { alumn_id: alumns(:two).id, guardian_id: guardians(:one).id } }, as: :json
    end

    assert_response :created
  end

  test "should show alumn_guardian" do
    get api_v1_alumn_guardian_url(@alumn_guardian), as: :json
    assert_response :success
  end

  test "should update alumn_guardian" do
    patch api_v1_alumn_guardian_url(@alumn_guardian), params: { alumn_guardian: { alumn_id: @alumn_guardian.alumn_id, guardian_id: @alumn_guardian.guardian_id } }, as: :json
    assert_response :success
  end

  test "should destroy alumn_guardian" do
    assert_difference("AlumnGuardian.count", -1) do
      delete api_v1_alumn_guardian_url(@alumn_guardian), as: :json
    end

    assert_response :success
  end
end
