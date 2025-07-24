class RemoveUserFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :user_id
    add_column :orders, :user_email, :string
  end
end
