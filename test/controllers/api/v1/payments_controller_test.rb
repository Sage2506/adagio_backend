require "test_helper"

class Api::V1::PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription = subscriptions(:one)
    @alumn = @subscription.alumn
  end

  test "partial payment does not move due_date and accumulates paid_amount" do
    post_payment(quantity: 1.0)

    @subscription.reload
    assert_equal 1.0, @subscription.paid_amount
    assert_equal Date.new(2025, 3, 9), @subscription.due_date
  end

  test "exact payment moves due_date by the plan duration and resets paid_amount" do
    post_payment(quantity: @subscription.plan.price)

    @subscription.reload
    assert_equal Date.new(2025, 3, 9) + @subscription.plan.subscription_duration, @subscription.due_date
    assert_equal 0.0, @subscription.paid_amount
  end

  test "overpayment moves due_date and keeps the remainder in paid_amount" do
    overpaid_quantity = @subscription.plan.price + 0.5
    post_payment(quantity: overpaid_quantity)

    @subscription.reload
    assert_equal Date.new(2025, 3, 9) + @subscription.plan.subscription_duration, @subscription.due_date
    assert_in_delta 0.5, @subscription.paid_amount, 0.001
  end

  test "partially pays an order" do
    order = Order.create!(alumn: @alumn, total: 100)

    post_order_payment(order: order, quantity: 40)

    assert_response :created
    assert_predicate order.reload, :partial?
    assert_equal 40, order.paid_amount
    assert_equal 60, order.remaining_balance
  end

  test "pays exactly the remaining order balance" do
    order = Order.create!(alumn: @alumn, total: 100, paid_amount: 40, status: :partial)

    post_order_payment(order: order, quantity: 60)

    assert_response :created
    assert_predicate order.reload, :paid?
    assert_equal 100, order.paid_amount
    assert_equal 0, order.remaining_balance
  end

  test "rejects an order payment above the remaining balance and rolls back" do
    order = Order.create!(alumn: @alumn, total: 100, paid_amount: 40, status: :partial)

    assert_no_difference -> { Payment.count } do
      assert_no_difference -> { OrderPayment.count } do
        post_order_payment(order: order, quantity: 61)
      end
    end

    assert_response :unprocessable_entity
    assert_equal 60, response.parsed_body.fetch("remaining_balance").to_d
    assert_equal 40, order.reload.paid_amount
  end

  test "rejects a payment for an already paid order" do
    order = Order.create!(alumn: @alumn, total: 100, paid_amount: 100, status: :paid)

    assert_no_difference -> { Payment.count } do
      post_order_payment(order: order, quantity: 1)
    end

    assert_response :unprocessable_entity
    assert_equal 0, response.parsed_body.fetch("remaining_balance").to_d
    assert_includes response.parsed_body.dig("errors", "base"), "Order is already paid"
  end

  test "requires payable type and id" do
    assert_no_difference -> { Payment.count } do
      authenticated_post(
        payment: { alumn_id: @alumn.id, quantity: 1 }
      )
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig("errors", "payable_type").present?
    assert response.parsed_body.dig("errors", "payable_id").present?
  end

  test "rejects non-positive payment quantities" do
    order = Order.create!(alumn: @alumn, total: 100)

    assert_no_difference -> { Payment.count } do
      [ 0, -1 ].each do |quantity|
        post_order_payment(order: order, quantity: quantity)

        assert_response :unprocessable_entity
        assert response.parsed_body.dig("errors", "quantity").present?
      end
    end
  end

  test "returns not found and rolls back for an unknown order" do
    assert_no_difference -> { Payment.count } do
      authenticated_post(
        payment: { alumn_id: @alumn.id, quantity: 1 },
        payable_type: "order",
        payable_id: Order.maximum(:id).to_i + 1
      )
    end

    assert_response :not_found
    assert response.parsed_body.dig("errors", "payable_id").present?
  end

  test "does not update a payment linked to an order" do
    order, payment = create_order_payment
    original_paid_at = payment.paid_at

    authenticated_patch(payment, quantity: 1, paid_at: "2026-01-01")

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.dig("errors", "base"), "Order payments cannot be modified"
    assert_equal 5, payment.reload.quantity
    assert_equal original_paid_at, payment.paid_at
    assert_equal 5, order.reload.paid_amount
  end

  test "does not delete a payment linked to an order" do
    order, payment = create_order_payment

    assert_no_difference -> { Payment.count } do
      authenticated_delete(payment)
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig("errors", "base").present?
    assert Payment.exists?(payment.id)
    assert_equal 5, order.reload.paid_amount
  end

  private

  def post_payment(quantity:)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      post api_v1_payments_url,
        params: {
          payment: { alumn_id: @alumn.id, quantity: quantity },
          payable_type: "subscription",
          payable_id: @subscription.id
        },
        headers: { "Authorization" => "Bearer faketoken" },
        as: :json
    end
    assert_response :created
  end

  def post_order_payment(order:, quantity:)
    authenticated_post(
      payment: { alumn_id: order.alumn_id, quantity: quantity },
      payable_type: "order",
      payable_id: order.id
    )
  end

  def authenticated_post(payload)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      post api_v1_payments_url,
        params: payload,
        headers: { "Authorization" => "Bearer faketoken" },
        as: :json
    end
  end

  def authenticated_patch(payment, attributes)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      patch api_v1_payment_url(payment),
        params: { payment: attributes },
        headers: { "Authorization" => "Bearer faketoken" },
        as: :json
    end
  end

  def authenticated_delete(payment)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      delete api_v1_payment_url(payment),
        headers: { "Authorization" => "Bearer faketoken" },
        as: :json
    end
  end

  def create_order_payment
    order = Order.create!(alumn: @alumn, total: 10)
    payment = Payment.create!(alumn: @alumn, quantity: 5)
    order.register_payment!(payment)

    [ order, payment ]
  end
end
