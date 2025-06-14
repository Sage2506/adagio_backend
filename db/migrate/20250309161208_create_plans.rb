class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.float :price
      t.integer :subscription_duration
      t.integer :tolerance_days
      t.boolean :is_active

      t.timestamps
    end
  end
end
