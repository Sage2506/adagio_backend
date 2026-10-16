require "test_helper"

class Api::V1::AdditionalIncomesControllerTest < ActionDispatch::IntegrationTest
  test "creates a MercadoPago commission expense for card income" do
    assert_difference -> { AdditionalIncome.count }, 1 do
      assert_difference -> { Expense.count }, 1 do
        authenticated_post(
          additional_income: {
            amount: 250,
            category: "events",
            payment_method: "card",
            date: "2026-10-16",
            description: "Event income"
          }
        )
      end
    end

    assert_response :created
    commission = Expense.last
    assert_equal 10.15, commission.amount.to_f
    assert_equal "commission", commission.category
    assert_equal "card", commission.payment_method
    assert_equal Date.new(2026, 10, 16), commission.date
    assert_equal "tester@example.com", commission.user_email
  end

  test "does not create a commission expense for transfer income" do
    assert_difference -> { AdditionalIncome.count }, 1 do
      assert_no_difference -> { Expense.count } do
        authenticated_post(
          additional_income: {
            amount: 250,
            category: "events",
            payment_method: "transfer",
            date: "2026-10-16",
            description: "Event income"
          }
        )
      end
    end

    assert_response :created
  end

  private

  def authenticated_post(payload)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      post api_v1_additional_incomes_url,
        params: payload,
        headers: { "Authorization" => "******" },
        as: :json
    end
  end
end
