require "test_helper"

class Api::V1::AlumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn = alumns(:one)
  end

  test "should get index" do
    get api_v1_alumns_url, as: :json
    assert_response :success
  end

  test "exports all filtered alumns as an Excel file with full names" do
    exported_alumn = Alumn.create!(name: "Exported", last_name: "Student", email: "exported.student@example.com", is_active: true)

    get "#{api_v1_alumns_url}?export=excel", as: :json

    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    assert_includes response.headers["Content-Disposition"], "filename=\"alumns.xlsx\""
    assert_includes response.body, "PK"
  ensure
    exported_alumn&.destroy!
  end

  test "filters alumns by inclusive age range" do
    included = Alumn.create!(name: "included", last_name: "range", email: "included.range@example.com", birth_date: Date.current - 8.years)
    excluded = Alumn.create!(name: "excluded", last_name: "range", email: "excluded.range@example.com", birth_date: Date.current - 9.years)

    get "#{api_v1_alumns_url}?min_age=4&max_age=8", as: :json

    assert_response :success
    response_ids = response.parsed_body.fetch("data").pluck("id")
    assert_includes response_ids, included.id
    assert_not_includes response_ids, excluded.id
  end

  test "filters alumns by any selected discipline" do
    discipline = disciplines(:one)
    plan = Plan.create!(name: "Filtered Plan", price: 10, subscription_duration: 30, tolerance_days: 5, is_active: true)
    plan.disciplines << discipline
    alumn = Alumn.create!(name: "discipline", last_name: "match", email: "discipline.match@example.com", is_active: true)
    Subscription.create!(plan: plan, alumn: alumn, status: :active, subscribed_at: Date.current)

    get "#{api_v1_alumns_url}?discipline_ids%5B%5D=#{discipline.id}", as: :json

    assert_response :success
    assert_includes response.parsed_body.fetch("data").pluck("id"), alumn.id
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
          email: "elena.lopez@example.com",
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
          phone_number: "+5491123456789",
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
          email: "elena.22@example.com",
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
