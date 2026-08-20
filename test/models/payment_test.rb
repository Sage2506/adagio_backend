require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "belongs to an alumn" do
    assert_equal :belongs_to, Payment.reflect_on_association(:alumn).macro
  end

  test "restricts deletion when linked to an order" do
    association = Payment.reflect_on_association(:order_payment)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "does not delete a payment linked to an order" do
    order = Order.create!(alumn: alumns(:one), total: 10)
    payment = Payment.create!(alumn: alumns(:one), quantity: 5)
    order.register_payment!(payment)

    assert_no_difference -> { Payment.count } do
      assert_not payment.destroy
    end

    assert Payment.exists?(payment.id)
    assert OrderPayment.exists?(order: order, payment: payment)
  end

  test "requires a positive quantity" do
    payment = Payment.new(alumn: alumns(:one), quantity: 0)

    assert_not payment.valid?
    assert_includes payment.errors[:quantity], "must be greater than 0"
  end

  test "cannot be updated when linked to an order" do
    order = Order.create!(alumn: alumns(:one), total: 10)
    payment = Payment.create!(alumn: alumns(:one), quantity: 5)
    order.register_payment!(payment)

    assert_not payment.update(quantity: 1)
    assert_includes payment.errors[:base], "Order payments cannot be modified"
    assert_equal 5, payment.reload.quantity
  end
end
