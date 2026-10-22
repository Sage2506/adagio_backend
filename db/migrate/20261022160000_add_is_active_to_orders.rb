class AddIsActiveToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :is_active, :boolean, null: false, default: true
  end
end
