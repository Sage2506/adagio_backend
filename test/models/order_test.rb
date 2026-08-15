require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "belongs to an alumn" do
    assert_equal :belongs_to, Order.reflect_on_association(:alumn).macro
  end

  test "accesses products through order products" do
    association = Order.reflect_on_association(:products)

    assert_equal :has_many, association.macro
    assert_equal :order_products, association.options[:through]
  end

  test "destroys product lines with the order" do
    association = Order.reflect_on_association(:order_products)

    assert_equal :destroy, association.options[:dependent]
  end

  test "restricts deletion when payments exist" do
    association = Order.reflect_on_association(:order_payments)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "destroys product lines when deleting an unpaid order" do
    order = create_order(total: products(:one).price)
    line = order.order_products.create!(product: products(:one), quantity: 1, price: products(:one).price)

    assert_difference -> { Order.count }, -1 do
      assert_difference -> { OrderProduct.count }, -1 do
        order.destroy!
      end
    end

    assert_not OrderProduct.exists?(line.id)
  end

  test "does not delete an order with payment history" do
    order = create_order(total: 100)
    payment = create_payment(order: order, quantity: 40)
    order.register_payment!(payment)

    assert_no_difference -> { Order.count } do
      assert_not order.destroy
    end

    assert_includes order.errors[:base], "Cannot delete record because dependent order payments exist"
    assert Order.exists?(order.id)
    assert Payment.exists?(payment.id)
  end

  test "registers a partial payment" do
    order = create_order(total: 100)
    payment = create_payment(order: order, quantity: 40)

    order.register_payment!(payment)

    assert_predicate order.reload, :partial?
    assert_equal 40, order.paid_amount
    assert_equal 60, order.remaining_balance
    assert_includes order.payments, payment
  end

  test "registers a payment that completes the order" do
    order = create_order(total: 100, paid_amount: 40)
    payment = create_payment(order: order, quantity: 60)

    order.register_payment!(payment)

    assert_predicate order.reload, :paid?
    assert_equal 100, order.paid_amount
    assert_equal 0, order.remaining_balance
  end

  test "rejects a payment above the remaining balance" do
    order = create_order(total: 100, paid_amount: 40)
    payment = create_payment(order: order, quantity: 61)

    error = assert_raises(ActiveRecord::RecordInvalid) do
      order.register_payment!(payment)
    end

    assert_includes error.record.errors.full_messages, "Payment quantity exceeds remaining balance"
    assert_equal 40, order.reload.paid_amount
    assert_not order.order_payments.exists?(payment: payment)
  end

  test "rejects payments for an already paid order" do
    order = create_order(total: 100, paid_amount: 100)
    payment = create_payment(order: order, quantity: 1)

    error = assert_raises(ActiveRecord::RecordInvalid) do
      order.register_payment!(payment)
    end

    assert_includes error.record.errors.full_messages, "Order is already paid"
    assert_not order.order_payments.exists?(payment: payment)
  end

  test "rejects a payment from another alumn" do
    order = create_order(total: 100)
    payment = Payment.create!(alumn_id: alumns(:two).id, quantity: 10)

    error = assert_raises(ActiveRecord::RecordInvalid) do
      order.register_payment!(payment)
    end

    assert_includes error.record.errors.full_messages, "Payment alumn must match order alumn"
  end

  test "validates monetary boundaries" do
    assert_not create_order(total: 0, save: false).valid?
    assert_not create_order(total: 100, paid_amount: -1, save: false).valid?
    assert_not create_order(total: 100, paid_amount: 101, save: false).valid?
  end

  private

  def create_order(total:, paid_amount: 0, save: true)
    status = if paid_amount.zero?
      :pending
    elsif paid_amount < total
      :partial
    else
      :paid
    end
    order = Order.new(alumn: alumns(:one), total: total, paid_amount: paid_amount, status: status)
    save ? order.tap(&:save!) : order
  end

  def create_payment(order:, quantity:)
    Payment.create!(alumn_id: order.alumn_id, quantity: quantity)
  end
end
