require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "accesses orders through order products" do
    association = Product.reflect_on_association(:orders)

    assert_equal :has_many, association.macro
    assert_equal :order_products, association.options[:through]
  end

  test "restricts deletion when used by an order" do
    association = Product.reflect_on_association(:order_products)

    assert_equal :restrict_with_error, association.options[:dependent]
  end
end