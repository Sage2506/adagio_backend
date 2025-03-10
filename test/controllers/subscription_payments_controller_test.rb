require "test_helper"

class SubscriptionPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription_payment = subscription_payments(:one)
  end

  test "should get index" do
    get subscription_payments_url, as: :json
    assert_response :success
  end

  test "should create subscription_payment" do
    assert_difference("SubscriptionPayment.count") do
      post subscription_payments_url, params: { subscription_payment: { payment_id: @subscription_payment.payment_id, subcription_id: @subscription_payment.subcription_id } }, as: :json
    end

    assert_response :created
  end

  test "should show subscription_payment" do
    get subscription_payment_url(@subscription_payment), as: :json
    assert_response :success
  end

  test "should update subscription_payment" do
    patch subscription_payment_url(@subscription_payment), params: { subscription_payment: { payment_id: @subscription_payment.payment_id, subcription_id: @subscription_payment.subcription_id } }, as: :json
    assert_response :success
  end

  test "should destroy subscription_payment" do
    assert_difference("SubscriptionPayment.count", -1) do
      delete subscription_payment_url(@subscription_payment), as: :json
    end

    assert_response :no_content
  end
end
