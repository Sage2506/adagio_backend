require "test_helper"

class Api::V1::AlumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn = alumns(:one)
  end

  test "should get index" do
    get api_v1_alumns_url, as: :json
    assert_response :success
  end

  test "should create alumn" do
    assert_difference("Alumn.count") do
      post api_v1_alumns_url, params: { alumn: { address: @alumn.address, email: @alumn.email, is_active: @alumn.is_active, last_name: @alumn.last_name, name: @alumn.name, phone_number: @alumn.phone_number } }, as: :json
    end

    assert_response :created
  end

  test "should show alumn" do
    get api_v1_alumn_url(@alumn), as: :json
    assert_response :success
  end

  test "should update alumn" do
    patch api_v1_alumn_url(@alumn), params: { alumn: { address: @alumn.address, email: @alumn.email, is_active: @alumn.is_active, last_name: @alumn.last_name, name: @alumn.name, phone_number: @alumn.phone_number } }, as: :json
    assert_response :success
  end

  test "should destroy alumn" do
    delete api_v1_alumn_url(@alumn), as: :json

    assert_response :success
    assert_not @alumn.reload.is_active
  end

  test "creates a subscription due on the first when enrolled on day 7" do
    plan = plans(:one)
    assert_difference [ "Alumn.count", "Subscription.count" ], 1 do
      post api_v1_alumns_url, params: {
        alumn: {
          name: "Elena",
          last_name: "Lopez",
          birth_date: "2017-07-07",
          subscription_attributes: {
            plan_id: plan.id,
            subscribed_at: "2026-08-07"
          }
        }
      }, as: :json
    end
    assert_response :created
    subscription = Alumn.last.subscription
    assert_equal Date.new(2026, 8, 1), subscription.due_date
  end

  test "creates a subscription due on the 15 when enrolled on day 8" do
    plan = plans(:one)
    assert_difference [ "Alumn.count", "Subscription.count" ], 1 do
      post api_v1_alumns_url, params: {
        alumn: {
          name: "Elena",
          last_name: "Lopez",
          birth_date: "2017-07-07",
          subscription_attributes: {
            plan_id: plan.id,
            subscribed_at: "2026-08-08"
          }
        }
      }, as: :json
    end
    assert_response :created
    subscription = Alumn.last.subscription
    assert_equal Date.new(2026, 8, 15), subscription.due_date
  end

  test "creates a subscription due on the first of the next month when enrolled on day 22" do
    plan = plans(:one)
    assert_difference [ "Alumn.count", "Subscription.count" ], 1 do
      post api_v1_alumns_url, params: {
        alumn: {
          name: "Elena",
          last_name: "Lopez",
          birth_date: "2017-07-07",
          subscription_attributes: {
            plan_id: plan.id,
            subscribed_at: "2026-08-22"
          }
        }
      }, as: :json
    end
    assert_response :created
    subscription = Alumn.last.subscription
    assert_equal Date.new(2026, 9, 1), subscription.due_date
  end
end
