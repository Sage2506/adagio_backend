class AddUserEmailToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :user_email, :string
  end
end
