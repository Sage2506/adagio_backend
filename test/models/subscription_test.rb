require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def subscription_with(day:, month: 6, year: 2025)
    Subscription.new(plan: plans(:one), alumn: alumns(:one), subscribed_at: Date.new(year, month, day))
  end

  test "day 1 (start of 1-7 range) sets due_date to day 1 of the current month" do
    subscription = subscription_with(day: 1)
    assert_equal Date.new(2025, 6, 1), subscription.calculate_due_date
  end

  test "day 7 (end of 1-7 range) sets due_date to day 1 of the current month" do
    subscription = subscription_with(day: 7)
    assert_equal Date.new(2025, 6, 1), subscription.calculate_due_date
  end

  test "day 8 (start of 8-21 range) sets due_date to day 15 of the current month" do
    subscription = subscription_with(day: 8)
    assert_equal Date.new(2025, 6, 15), subscription.calculate_due_date
  end

  test "day 21 (end of 8-21 range) sets due_date to day 15 of the current month" do
    subscription = subscription_with(day: 21)
    assert_equal Date.new(2025, 6, 15), subscription.calculate_due_date
  end

  test "day 22 (start of 22-31 range) sets due_date to day 1 of next month" do
    subscription = subscription_with(day: 22)
    assert_equal Date.new(2025, 7, 1), subscription.calculate_due_date
  end

  test "day 31 (end of 22-31 range) sets due_date to day 1 of next month" do
    subscription = subscription_with(day: 31, month: 7)
    assert_equal Date.new(2025, 8, 1), subscription.calculate_due_date
  end

  test "day 31 in January uses the next month boundary correctly when the month has 31 days" do
    subscription = subscription_with(day: 31, month: 1)
    assert_equal Date.new(2025, 2, 1), subscription.calculate_due_date
  end

  test "handles year rollover for the 1-7 range" do
    subscription = subscription_with(day: 5, month: 12)
    assert_equal Date.new(2025, 12, 1), subscription.calculate_due_date
  end

  test "handles year rollover for the 22-31 range" do
    subscription = subscription_with(day: 25, month: 12)
    assert_equal Date.new(2026, 1, 1), subscription.calculate_due_date
  end

  test "falls back to Date.today when subscribed_at is blank" do
    travel_to Date.new(2025, 6, 10) do
      subscription = Subscription.new(plan: plans(:one), alumn: alumns(:one))
      assert_equal Date.new(2025, 6, 15), subscription.calculate_due_date
    end
  end

  test "day 26 sets due_date to day 1 of next month" do
    subscription = subscription_with(day: 26, month: 8, year: 2026)

    assert_equal Date.new(2026, 9, 1), subscription.calculate_due_date
  end

  test "uses a custom price for subscription balances" do
    subscription = Subscription.new(plan: plans(:one), alumn: alumns(:one), custom_price: 120, paid_amount: 20)

    assert_equal 120, subscription.effective_price
    assert_equal 100, subscription.remaining_balance
    assert_not_predicate subscription, :fully_paid?
  end

  test "uses the plan price when custom price is absent" do
    subscription = Subscription.new(plan: plans(:one), alumn: alumns(:one), paid_amount: 0.5)

    assert_equal plans(:one).price, subscription.effective_price
    assert_in_delta 1.0, subscription.remaining_balance, 0.001
  end

  test "rejects non-positive custom prices" do
    subscription = Subscription.new(plan: plans(:one), alumn: alumns(:one), custom_price: 0)

    assert_not_predicate subscription, :valid?
    assert_includes subscription.errors[:custom_price], "must be greater than 0"
  end
end
