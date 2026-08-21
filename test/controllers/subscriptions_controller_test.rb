require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription = subscriptions(:one)
  end

  test "should get index" do
    get api_v1_subscriptions_url, as: :json
    assert_response :success
  end

  test "should create subscription" do
    assert_difference("Subscription.count") do
      post api_v1_subscriptions_url, params: { subscription: { alumn_id: @subscription.alumn_id, due_date: @subscription.due_date, last_payment_date: @subscription.last_payment_date, plan_id: @subscription.plan_id, status: @subscription.status } }, as: :json
    end

    assert_response :created
  end

  test "should show subscription" do
    get api_v1_subscription_url(@subscription), as: :json
    assert_response :success
  end

  test "should update subscription" do
    patch api_v1_subscription_url(@subscription), params: { subscription: { alumn_id: @subscription.alumn_id, due_date: @subscription.due_date, last_payment_date: @subscription.last_payment_date, plan_id: @subscription.plan_id, status: @subscription.status } }, as: :json
    assert_response :success
  end

  test "should destroy subscription" do
    delete api_v1_subscription_url(@subscription), as: :json

    assert_response :success
    assert_equal "cancelled", @subscription.reload.status
  end
end
