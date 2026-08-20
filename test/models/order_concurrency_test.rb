require "test_helper"

class OrderConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @alumn = Alumn.create!(
      name: "Concurrent",
      last_name: "Payment",
      email: "concurrent-#{SecureRandom.hex(6)}@example.com"
    )
    @order = Order.create!(alumn: @alumn, total: 100)
    @payments = 2.times.map { Payment.create!(alumn: @alumn, quantity: 60) }
  end

  teardown do
    OrderPayment.where(order_id: @order.id).delete_all
    Payment.where(id: @payments.map(&:id)).delete_all
    Order.where(id: @order.id).delete_all
    Alumn.where(id: @alumn.id).delete_all
  end

  test "serializes simultaneous payments and prevents exceeding the balance" do
    ready = Queue.new
    start = Queue.new
    results = Queue.new

    threads = @payments.map do |payment|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          start.pop

          begin
            Order.find(@order.id).register_payment!(Payment.find(payment.id))
            results << :accepted
          rescue ActiveRecord::RecordInvalid => error
            results << error.record.errors.full_messages
          end
        end
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    threads.each(&:join)
    outcomes = 2.times.map { results.pop }

    assert_equal 1, outcomes.count(:accepted)
    assert_equal 1, outcomes.count { |outcome| outcome.is_a?(Array) && outcome.include?("Payment quantity exceeds remaining balance") }
    assert_equal 60, @order.reload.paid_amount
    assert_predicate @order, :partial?
    assert_equal 1, @order.order_payments.count
  end
end
