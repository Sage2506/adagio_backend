class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :alumn, null: false, foreign_key: true
      t.references :payment, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.integer :status
      t.float :total
      t.string :description

      t.timestamps
    end
  end
end
