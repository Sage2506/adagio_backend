require "test_helper"

class UserDisciplinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_discipline = user_disciplines(:one)
  end

  test "should get index" do
    get api_v1_user_disciplines_url, as: :json
    assert_response :success
  end

  test "should create user_discipline" do
    assert_difference("UserDiscipline.count") do
      post api_v1_user_disciplines_url, params: { user_discipline: { discipline_id: @user_discipline.discipline_id, user_id: @user_discipline.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show user_discipline" do
    get api_v1_user_discipline_url(@user_discipline), as: :json
    assert_response :success
  end

  test "should update user_discipline" do
    patch api_v1_user_discipline_url(@user_discipline), params: { user_discipline: { discipline_id: @user_discipline.discipline_id, user_id: @user_discipline.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy user_discipline" do
    assert_difference("UserDiscipline.count", -1) do
      delete api_v1_user_discipline_url(@user_discipline), as: :json
    end

    assert_response :no_content
  end
end
