class HardenOrderPaymentIntegrity < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE orders
      SET paid_amount = 0
      WHERE paid_amount IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE orders
      SET status = CASE
        WHEN paid_amount = 0 THEN 0
        WHEN paid_amount < total THEN 1
        ELSE 2
      END
    SQL

    change_column :orders, :total, :decimal,
      precision: 12, scale: 2, using: "ROUND(total::numeric, 2)"
    change_column :orders, :paid_amount, :decimal,
      precision: 12, scale: 2, using: "ROUND(paid_amount::numeric, 2)"
    change_column :order_products, :price, :decimal,
      precision: 12, scale: 2, using: "ROUND(price::numeric, 2)"
    change_column :payments, :quantity, :decimal,
      precision: 12, scale: 2, using: "ROUND(quantity::numeric, 2)"
    change_column :products, :price, :decimal,
      precision: 12, scale: 2, using: "ROUND(price::numeric, 2)"

    change_column_default :orders, :paid_amount, from: nil, to: 0
    change_column_default :orders, :status, from: nil, to: 0

    change_column_null :orders, :total, false
    change_column_null :orders, :paid_amount, false
    change_column_null :orders, :status, false
    change_column_null :order_products, :price, false
    change_column_null :order_products, :quantity, false
    change_column_null :payments, :quantity, false
    change_column_null :products, :price, false

    add_index :order_payments, [ :order_id, :payment_id ],
      unique: true, name: "index_order_payments_on_order_and_payment"
    add_index :order_products, [ :order_id, :product_id ],
      unique: true, name: "index_order_products_on_order_and_product"

    add_check_constraint :orders, "total > 0",
      name: "orders_total_positive", validate: false
    add_check_constraint :orders, "paid_amount >= 0",
      name: "orders_paid_amount_non_negative"
    add_check_constraint :orders, "paid_amount <= total",
      name: "orders_paid_amount_not_above_total"
    add_check_constraint :orders, "status IN (0, 1, 2)",
      name: "orders_status_valid"
    add_check_constraint :order_products, "price > 0",
      name: "order_products_price_positive"
    add_check_constraint :order_products, "quantity > 0",
      name: "order_products_quantity_positive"
    add_check_constraint :payments, "quantity > 0",
      name: "payments_quantity_positive"
    add_check_constraint :products, "price > 0",
      name: "products_price_positive"
  end

  def down
    remove_check_constraint :products, name: "products_price_positive"
    remove_check_constraint :payments, name: "payments_quantity_positive"
    remove_check_constraint :order_products, name: "order_products_quantity_positive"
    remove_check_constraint :order_products, name: "order_products_price_positive"
    remove_check_constraint :orders, name: "orders_status_valid"
    remove_check_constraint :orders, name: "orders_paid_amount_not_above_total"
    remove_check_constraint :orders, name: "orders_paid_amount_non_negative"
    remove_check_constraint :orders, name: "orders_total_positive"

    remove_index :order_products, name: "index_order_products_on_order_and_product"
    remove_index :order_payments, name: "index_order_payments_on_order_and_payment"

    change_column_null :products, :price, true
    change_column_null :payments, :quantity, true
    change_column_null :order_products, :quantity, true
    change_column_null :order_products, :price, true
    change_column_null :orders, :status, true
    change_column_null :orders, :paid_amount, true
    change_column_null :orders, :total, true

    change_column_default :orders, :status, from: 0, to: nil
    change_column_default :orders, :paid_amount, from: 0, to: nil

    change_column :products, :price, :float
    change_column :payments, :quantity, :float
    change_column :order_products, :price, :float
    change_column :orders, :paid_amount, :float
    change_column :orders, :total, :float
  end
end
