class CreateSubscriptionPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_payments do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
