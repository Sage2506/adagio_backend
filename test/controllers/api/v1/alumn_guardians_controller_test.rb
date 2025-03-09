require "test_helper"

class Api::V1::AlumnGuardiansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn_guardian = alumn_guardians(:one)
  end

  test "should get index" do
    get alumn_guardians_url, as: :json
    assert_response :success
  end

  test "should create alumn_guardian" do
    assert_difference("Api::V1::AlumnGuardian.count") do
      post alumn_guardians_url, params: { alumn_guardian: { alumn_id: @alumn_guardian.alumn_id, guardian_id: @alumn_guardian.guardian_id } }, as: :json
    end

    assert_response :created
  end

  test "should show alumn_guardian" do
    get alumn_guardian_url(@alumn_guardian), as: :json
    assert_response :success
  end

  test "should update alumn_guardian" do
    patch alumn_guardian_url(@alumn_guardian), params: { alumn_guardian: { alumn_id: @alumn_guardian.alumn_id, guardian_id: @alumn_guardian.guardian_id } }, as: :json
    assert_response :success
  end

  test "should destroy alumn_guardian" do
    assert_difference("Api::V1::AlumnGuardian.count", -1) do
      delete alumn_guardian_url(@alumn_guardian), as: :json
    end

    assert_response :no_content
  end
end
