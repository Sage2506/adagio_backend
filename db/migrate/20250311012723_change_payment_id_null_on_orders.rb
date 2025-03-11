class ChangePaymentIdNullOnOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :payment_id, true
  end
end
