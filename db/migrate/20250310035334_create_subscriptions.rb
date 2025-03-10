class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :alumn, null: false, foreign_key: true
      t.date :due_date
      t.integer :status
      t.date :last_payment_date

      t.timestamps
    end
  end
end
