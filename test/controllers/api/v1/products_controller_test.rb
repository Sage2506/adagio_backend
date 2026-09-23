require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get api_v1_products_url, as: :json
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post api_v1_products_url, params: { product: { description: @product.description, name: @product.name, price: @product.price } }, as: :json
    end

    assert_response :created
  end

  test "should show product" do
    get api_v1_product_url(@product), as: :json
    assert_response :success
  end

  test "should update product" do
    patch api_v1_product_url(@product), params: { product: { description: @product.description, name: @product.name, price: @product.price } }, as: :json
    assert_response :success
  end

  test "should destroy product" do
    product = Product.create!(name: "Temp", price: 1.5, description: "Temp")

    delete api_v1_product_url(product), as: :json

    assert_response :success
    assert_not product.reload.is_active
  end

  test "does not return inactive products in index" do
    active_product = Product.create!(name: "Active", price: 1.5, description: "Active")
    inactive_product = Product.create!(name: "Inactive", price: 1.5, description: "Inactive", is_active: false)

    get api_v1_products_url, as: :json

    assert_response :success
    product_ids = response.parsed_body.fetch("data").pluck("id")
    assert_includes product_ids, active_product.id
    assert_not_includes product_ids, inactive_product.id
  end
end
