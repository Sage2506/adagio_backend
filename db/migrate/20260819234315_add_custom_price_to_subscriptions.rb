class AddCustomPriceToSubscriptions < ActiveRecord::Migration[8.1]
  def change
    add_column :subscriptions, :custom_price, :float
  end
end
