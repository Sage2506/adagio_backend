require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def subscription_with(day:, month: 6, year: 2025)
    Subscription.new(plan: plans(:one), alumn: alumns(:one), subscribed_at: Date.new(year, month, day))
  end

  test "day 1 (start of 1-7 range) sets due_date to day 1 of next month" do
    subscription = subscription_with(day: 1)
    assert_equal Date.new(2025, 7, 1), subscription.calculate_due_date
  end

  test "day 7 (end of 1-7 range) sets due_date to day 1 of next month" do
    subscription = subscription_with(day: 7)
    assert_equal Date.new(2025, 7, 1), subscription.calculate_due_date
  end

  test "day 8 (start of 8-21 range) sets due_date to day 15 of next month" do
    subscription = subscription_with(day: 8)
    assert_equal Date.new(2025, 7, 15), subscription.calculate_due_date
  end

  test "day 21 (end of 8-21 range) sets due_date to day 15 of next month" do
    subscription = subscription_with(day: 21)
    assert_equal Date.new(2025, 7, 15), subscription.calculate_due_date
  end

  test "day 22 (start of 22-31 range) sets due_date to day 1 in two months" do
    subscription = subscription_with(day: 22)
    assert_equal Date.new(2025, 8, 1), subscription.calculate_due_date
  end

  test "day 31 (end of 22-31 range) sets due_date to day 1 in two months" do
    subscription = subscription_with(day: 31, month: 7)
    assert_equal Date.new(2025, 9, 1), subscription.calculate_due_date
  end

  test "handles year rollover for the 1-7 range" do
    subscription = subscription_with(day: 5, month: 12)
    assert_equal Date.new(2026, 1, 1), subscription.calculate_due_date
  end

  test "handles year rollover for the 22-31 range" do
    subscription = subscription_with(day: 25, month: 12)
    assert_equal Date.new(2026, 2, 1), subscription.calculate_due_date
  end

  test "falls back to Date.today when subscribed_at is blank" do
    travel_to Date.new(2025, 6, 10) do
      subscription = Subscription.new(plan: plans(:one), alumn: alumns(:one))
      assert_equal Date.new(2025, 7, 15), subscription.calculate_due_date
    end
  end
end
