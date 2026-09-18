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

  test "add_credit accumulates paid_amount without moving due_date when below effective price" do
    @subscription.update!(paid_amount: 0.5, due_date: Date.new(2025, 3, 9))

    post_add_credit(amount: 0.75)

    @subscription.reload
    assert_response :ok
    assert_in_delta 1.25, @subscription.paid_amount, 0.001
    assert_equal Date.new(2025, 3, 9), @subscription.due_date
  end

  test "add_credit moves due_date forward and clears paid_amount when total reaches effective price" do
    @subscription.update!(paid_amount: 0.5, due_date: Date.new(2025, 3, 9))

    post_add_credit(amount: 1.0)

    @subscription.reload
    assert_response :ok
    assert_equal Date.new(2025, 4, 9), @subscription.due_date
    assert_in_delta 0.0, @subscription.paid_amount, 0.001
  end

  test "add_credit moves due_date forward and keeps the excess when total exceeds effective price" do
    @subscription.update!(paid_amount: 0.5, due_date: Date.new(2025, 3, 9))

    post_add_credit(amount: 2.0)

    @subscription.reload
    assert_response :ok
    assert_equal Date.new(2025, 4, 9), @subscription.due_date
    assert_in_delta 1.0, @subscription.paid_amount, 0.001
  end

  test "add_credit advances from January 31 to February 1 when the total reaches the effective price" do
    @subscription.update!(paid_amount: 0.5, due_date: Date.new(2025, 1, 31))

    post_add_credit(amount: 1.0)

    @subscription.reload
    assert_response :ok
    assert_equal Date.new(2025, 2, 1), @subscription.due_date
    assert_in_delta 0.0, @subscription.paid_amount, 0.001
  end

  test "add_credit rejects non-positive amounts" do
    assert_no_difference -> { @subscription.reload.paid_amount } do
      post_add_credit(amount: 0)
    end

    assert_response :unprocessable_entity
    assert_equal "El monto del crédito debe ser mayor a 0", response.parsed_body["error"]
  end

  private

  def post_add_credit(amount:)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      post add_credit_api_v1_subscription_url(@subscription),
        params: { amount: amount },
        headers: { "Authorization" => "Bearer faketoken" },
        as: :json
    end
  end
end
