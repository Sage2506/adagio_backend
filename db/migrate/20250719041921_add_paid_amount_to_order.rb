class AddPaidAmountToOrder < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :paid_amount, :float
  end
end
