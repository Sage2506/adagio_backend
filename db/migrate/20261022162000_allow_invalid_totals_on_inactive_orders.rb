class AllowInvalidTotalsOnInactiveOrders < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :orders, name: "orders_total_positive"
    add_check_constraint :orders, "is_active = false OR total > 0",
      name: "orders_total_positive", validate: false
  end

  def down
    remove_check_constraint :orders, name: "orders_total_positive"
    add_check_constraint :orders, "total > 0",
      name: "orders_total_positive", validate: false
  end
end
