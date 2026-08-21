require "test_helper"

class SubscriptionPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription_payment = subscription_payments(:one)
  end

  test "should get index" do
    get api_v1_subscription_payments_url, as: :json
    assert_response :success
  end

  test "should create subscription_payment" do
    assert_difference("SubscriptionPayment.count") do
      post api_v1_subscription_payments_url, params: { subscription_payment: { payment_id: @subscription_payment.payment_id, subscription_id: @subscription_payment.subscription_id } }, as: :json
    end

    assert_response :created
  end

  test "should show subscription_payment" do
    get api_v1_subscription_payment_url(@subscription_payment), as: :json
    assert_response :success
  end

  test "should update subscription_payment" do
    patch api_v1_subscription_payment_url(@subscription_payment), params: { subscription_payment: { payment_id: @subscription_payment.payment_id, subscription_id: @subscription_payment.subscription_id } }, as: :json
    assert_response :success
  end

  test "should destroy subscription_payment" do
    assert_difference("SubscriptionPayment.count", -1) do
      delete api_v1_subscription_payment_url(@subscription_payment), as: :json
    end

    assert_response :no_content
  end
end
