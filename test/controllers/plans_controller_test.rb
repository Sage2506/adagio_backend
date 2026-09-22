require "test_helper"

class PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plan = plans(:one)
  end

  test "should get index" do
    get api_v1_plans_url, as: :json
    assert_response :success
  end

  test "should create plan" do
    assert_difference("Plan.count") do
      post api_v1_plans_url, params: { plan: { is_active: @plan.is_active, name: @plan.name, price: @plan.price, subscription_duration: @plan.subscription_duration, tolerance_days: @plan.tolerance_days, discipline_ids: [ disciplines(:one).id ] } }, as: :json
    end

    assert_response :created
    assert_includes Plan.order(:id).last.discipline_ids, disciplines(:one).id
  end

  test "should show plan" do
    get api_v1_plan_url(@plan), as: :json
    assert_response :success
  end

  test "should update plan" do
    patch api_v1_plan_url(@plan), params: { plan: { is_active: @plan.is_active, name: @plan.name, price: @plan.price, subscription_duration: @plan.subscription_duration, tolerance_days: @plan.tolerance_days, discipline_ids: [ disciplines(:two).id ] } }, as: :json
    assert_response :success
    assert_equal [ disciplines(:two).id ], @plan.reload.discipline_ids
  end

  test "rejects a plan without disciplines" do
    assert_no_difference("Plan.count") do
      post api_v1_plans_url, params: { plan: { name: "Without discipline", price: 10, subscription_duration: 30, tolerance_days: 5, discipline_ids: [] } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should destroy plan" do
    delete api_v1_plan_url(@plan), as: :json

    assert_response :success
    assert_not @plan.reload.is_active
  end
end
