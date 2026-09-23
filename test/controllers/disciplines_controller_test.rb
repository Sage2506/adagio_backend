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

    delete api_v1_discipline_url(discipline), as: :json

    assert_response :success
    assert_not discipline.reload.is_active
  end

  test "does not return inactive disciplines in index" do
    active_discipline = Discipline.create!(name: "Active", is_active: true)
    inactive_discipline = Discipline.create!(name: "Inactive", is_active: false)

    get api_v1_disciplines_url, as: :json

    assert_response :success
    discipline_ids = response.parsed_body.fetch("data").pluck("id")
    assert_includes discipline_ids, active_discipline.id
    assert_not_includes discipline_ids, inactive_discipline.id
  end
end
