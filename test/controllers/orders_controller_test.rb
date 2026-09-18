require "test_helper"

class Api::V1::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alumn = alumns(:one)
    @first_product = products(:one)
    @second_product = products(:two)
  end

  test "creates a multi-product order using server prices" do
    assert_difference -> { Order.count }, 1 do
      assert_difference -> { OrderProduct.count }, 2 do
        post_order(
          order: { alumn_id: @alumn.id, total: 0.01 },
          products: [
            { id: @first_product.id, quantity: 2, price: 0.01 },
            { id: @second_product.id, quantity: 1, price: 0.01 }
          ]
        )
      end
    end

    assert_response :created
    order = Order.find(response.parsed_body.fetch("id"))
    expected_total = (@first_product.price * 2) + @second_product.price

    assert_equal expected_total, order.total
    assert_predicate order, :pending?
    assert_equal [ @first_product.price, @second_product.price ], order.order_products.order(:product_id).pluck(:price)
  end

  test "registers an advance through the order payment flow" do
    assert_difference -> { Payment.count }, 1 do
      assert_difference -> { OrderPayment.count }, 1 do
        post_order(
          order: { alumn_id: @alumn.id, paid_amount: 1 },
          products: [ { id: @first_product.id, quantity: 1 } ]
        )
      end
    end

    assert_response :created
    order = Order.find(response.parsed_body.fetch("id"))

    assert_predicate order, :partial?
    assert_equal 1, order.paid_amount
    assert_equal 1, order.payments.sum(:quantity)
    assert_predicate order.payments.first, :cash?
  end

  test "creates a paid order when the advance matches the calculated total" do
    post_order(
      order: { alumn_id: @alumn.id, paid_amount: @first_product.price },
      products: [ { id: @first_product.id, quantity: 1 } ]
    )

    assert_response :created
    order = Order.find(response.parsed_body.fetch("id"))

    assert_predicate order, :paid?
    assert_equal order.total, order.paid_amount
    assert_equal 0, order.remaining_balance
    assert_equal order.total, order.payments.sum(:quantity)
  end

  test "rejects an order without products" do
    assert_creation_rolls_back do
      post_order(order: { alumn_id: @alumn.id }, products: [])
    end

    assert_response :unprocessable_entity
  end

  test "rejects unknown products and rolls back" do
    assert_creation_rolls_back do
      post_order(
        order: { alumn_id: @alumn.id, paid_amount: 1 },
        products: [ { id: Product.maximum(:id) + 1, quantity: 1 } ]
      )
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig("errors", "products").present?
  end

  test "rejects invalid quantities and rolls back" do
    assert_creation_rolls_back do
      post_order(
        order: { alumn_id: @alumn.id },
        products: [ { id: @first_product.id, quantity: 0 } ]
      )
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.dig("errors", "products"), "Products quantity must be a positive integer"
  end

  test "rejects an advance above the calculated total and rolls back" do
    assert_creation_rolls_back do
      post_order(
        order: { alumn_id: @alumn.id, paid_amount: @first_product.price + 1 },
        products: [ { id: @first_product.id, quantity: 1 } ]
      )
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.dig("errors", "base"), "Payment quantity exceeds remaining balance"
  end

  test "lists financial summaries filtered by status and alumn" do
    matching_order = Order.create!(alumn: @alumn, total: 100, paid_amount: 40, status: :partial)
    other_order = Order.create!(alumn: alumns(:two), total: 100, paid_amount: 40, status: :partial)

    get_orders(status: "partial", alumn_id: @alumn.id)

    assert_response :success
    body = response.parsed_body
    record = body.fetch("data").find { |order| order["id"] == matching_order.id }

    assert record.present?
    assert_not body.fetch("data").any? { |order| order["id"] == other_order.id }
    assert_equal "partial", record["status"]
    assert_equal 100, record["total"]
    assert_equal 40, record["paid_amount"]
    assert_equal 60, record["remaining_balance"]
    assert_equal @alumn.id, record.dig("alumn", "id")
    assert body.key?("total")
    assert body.key?("links")
    assert body.key?("pages")
  end

  test "shows product lines and payment history" do
    order = Order.create!(alumn: @alumn, total: @first_product.price * 2)
    order.order_products.create!(product: @first_product, quantity: 2, price: @first_product.price)
    payment = Payment.create!(alumn: @alumn, quantity: 1)
    order.register_payment!(payment)

    get_order(order)

    assert_response :success
    body = response.parsed_body
    line = body.fetch("order_products").first
    history_item = body.fetch("payments").first

    assert_equal @alumn.id, body.dig("alumn", "id")
    assert_equal @first_product.id, line.dig("product", "id")
    assert_equal 2, line["quantity"]
    assert_equal @first_product.price, line["price"].to_d
    assert_equal payment.id, history_item["id"]
    assert_equal payment.quantity, history_item["quantity"].to_d
  end

  test "rejects invalid order filters" do
    get_orders(status: "unknown")

    assert_response :unprocessable_entity
    assert response.parsed_body.dig("errors", "status").present?

    get_orders(alumn_id: "invalid")

    assert_response :unprocessable_entity
    assert response.parsed_body.dig("errors", "alumn_id").present?
  end

  private

  def post_order(payload)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      post api_v1_orders_url,
        params: payload,
        headers: { "Authorization" => "Bearer fake" },
        as: :json
    end
  end

  def get_orders(params = {})
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      get api_v1_orders_url,
        params: params,
        headers: { "Authorization" => "Bearer fake" }
    end
  end

  def get_order(order)
    CognitoAuth.stub :verify_token, [ { "email" => "tester@example.com" } ] do
      get api_v1_order_url(order),
        headers: { "Authorization" => "Bearer fake" }
    end
  end

  def assert_creation_rolls_back
    before_counts = [ Order.count, OrderProduct.count, Payment.count, OrderPayment.count ]
    yield
    after_counts = [ Order.count, OrderProduct.count, Payment.count, OrderPayment.count ]

    assert_equal before_counts, after_counts
  end
end
