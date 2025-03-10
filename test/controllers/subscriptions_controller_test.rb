require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription = subscriptions(:one)
  end

  test "should get index" do
    get subscriptions_url, as: :json
    assert_response :success
  end

  test "should create subscription" do
    assert_difference("Subscription.count") do
      post subscriptions_url, params: { subscription: { alumn_id: @subscription.alumn_id, due_date: @subscription.due_date, last_payment_date: @subscription.last_payment_date, plan_id: @subscription.plan_id, status: @subscription.status } }, as: :json
    end

    assert_response :created
  end

  test "should show subscription" do
    get subscription_url(@subscription), as: :json
    assert_response :success
  end

  test "should update subscription" do
    patch subscription_url(@subscription), params: { subscription: { alumn_id: @subscription.alumn_id, due_date: @subscription.due_date, last_payment_date: @subscription.last_payment_date, plan_id: @subscription.plan_id, status: @subscription.status } }, as: :json
    assert_response :success
  end

  test "should destroy subscription" do
    assert_difference("Subscription.count", -1) do
      delete subscription_url(@subscription), as: :json
    end

    assert_response :no_content
  end
end
