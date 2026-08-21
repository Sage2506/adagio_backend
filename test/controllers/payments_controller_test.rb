require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment = payments(:one)
  end

  test "should get index" do
    get api_v1_payments_url, as: :json
    assert_response :success
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
