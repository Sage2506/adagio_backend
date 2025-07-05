class RemovePaymentFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :payment_id
  end
end
