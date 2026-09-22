require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment = payments(:one)
  end

  test "should get index" do
    get api_v1_payments_url, as: :json
    assert_response :success
  end

  test "index returns the most recent payments first" do
    older_payment = Payment.create!(alumn_id: @payment.alumn_id, quantity: 1, paid_at: 2.days.ago)
    newer_payment = Payment.create!(alumn_id: @payment.alumn_id, quantity: 1, paid_at: 1.day.ago)

    get api_v1_payments_url, as: :json

    assert_response :success
    payment_ids = response.parsed_body.fetch("data").pluck("id")
    assert_operator payment_ids.index(newer_payment.id), :<, payment_ids.index(older_payment.id)
  end

  test "should create payment" do
    assert_difference("Payment.count") do
      post api_v1_payments_url, params: { payment: { alumn_id: @payment.alumn_id, quantity: @payment.quantity }, payable_type: "subscription", payable_id: subscriptions(:two).id }, as: :json
    end

    assert_response :created
  end

  test "should show payment" do
    get api_v1_payment_url(@payment), as: :json
    assert_response :success
  end

  test "should update payment" do
    payment = Payment.create!(alumn_id: @payment.alumn_id, quantity: @payment.quantity)

    patch api_v1_payment_url(payment), params: { payment: { alumn_id: @payment.alumn_id, quantity: 9.99 } }, as: :json
    assert_response :success
  end

  test "should destroy payment" do
    payment = Payment.create!(alumn_id: @payment.alumn_id, quantity: @payment.quantity)

    assert_difference("Payment.count", -1) do
      delete api_v1_payment_url(payment), as: :json
    end

    assert_response :no_content
  end
end
