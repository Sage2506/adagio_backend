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

    assert_difference("Product.count", -1) do
      delete api_v1_product_url(product), as: :json
    end

    assert_response :no_content
  end
end
