require "test_helper"

class AssistancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assistance = assistances(:one)
  end

  test "should get index" do
    get assistances_url, as: :json
    assert_response :success
  end

  test "should create assistance" do
    assert_difference("Assistance.count") do
      post assistances_url, params: { assistance: { alumn_id: @assistance.alumn_id, lesson_id: @assistance.lesson_id } }, as: :json
    end

    assert_response :created
  end

  test "should show assistance" do
    get assistance_url(@assistance), as: :json
    assert_response :success
  end

  test "should update assistance" do
    patch assistance_url(@assistance), params: { assistance: { alumn_id: @assistance.alumn_id, lesson_id: @assistance.lesson_id } }, as: :json
    assert_response :success
  end

  test "should destroy assistance" do
    assert_difference("Assistance.count", -1) do
      delete assistance_url(@assistance), as: :json
    end

    assert_response :no_content
  end
end
