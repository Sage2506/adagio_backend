class RenameColumnTotalToQuantityFromPayments < ActiveRecord::Migration[8.0]
  def change
    rename_column :payments, :total, :quantity
  end
end
