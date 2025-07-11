class AddPaidAmountToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :paid_amount, :float, default: 0.0
  end
end
