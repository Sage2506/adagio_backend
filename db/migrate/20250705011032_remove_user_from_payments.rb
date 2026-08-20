class RemoveUserFromPayments < ActiveRecord::Migration[8.0]
  def change
    remove_column :payments, :user_id
  end
end
