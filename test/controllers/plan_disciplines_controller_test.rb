require "test_helper"

class PlanDisciplinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plan_discipline = plan_disciplines(:one)
  end

  test "should get index" do
    get api_v1_plan_disciplines_url, as: :json
    assert_response :success
  end

  test "should create plan_discipline" do
    assert_difference("PlanDiscipline.count") do
      post api_v1_plan_disciplines_url, params: { plan_discipline: { discipline_id: @plan_discipline.discipline_id, plan_id: @plan_discipline.plan_id } }, as: :json
    end

    assert_response :created
  end

  test "should show plan_discipline" do
    get api_v1_plan_discipline_url(@plan_discipline), as: :json
    assert_response :success
  end

  test "should update plan_discipline" do
    patch api_v1_plan_discipline_url(@plan_discipline), params: { plan_discipline: { discipline_id: @plan_discipline.discipline_id, plan_id: @plan_discipline.plan_id } }, as: :json
    assert_response :success
  end

  test "should destroy plan_discipline" do
    assert_difference("PlanDiscipline.count", -1) do
      delete api_v1_plan_discipline_url(@plan_discipline), as: :json
    end

    assert_response :no_content
  end
end
