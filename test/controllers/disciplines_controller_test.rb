require "test_helper"

class DisciplinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @discipline = disciplines(:one)
  end

  test "should get index" do
    get api_v1_disciplines_url, as: :json
    assert_response :success
  end

  test "should create discipline" do
    assert_difference("Discipline.count") do
      post api_v1_disciplines_url, params: { discipline: { is_active: @discipline.is_active, name: @discipline.name } }, as: :json
    end

    assert_response :created
  end

  test "should show discipline" do
    get api_v1_discipline_url(@discipline), as: :json
    assert_response :success
  end

  test "should update discipline" do
    patch api_v1_discipline_url(@discipline), params: { discipline: { is_active: @discipline.is_active, name: @discipline.name } }, as: :json
    assert_response :success
  end

  test "should destroy discipline" do
    discipline = Discipline.create!(name: "Temp", is_active: true)

    assert_difference("Discipline.count", -1) do
      delete api_v1_discipline_url(discipline), as: :json
    end

    assert_response :no_content
  end
end
