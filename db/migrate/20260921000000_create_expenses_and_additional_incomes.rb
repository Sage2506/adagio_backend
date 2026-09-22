class CreateExpensesAndAdditionalIncomes < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.decimal :amount, precision: 12, scale: 2
      t.integer :category
      t.string :description
      t.integer :payment_method
      t.date :date
      t.string :user_email

      t.timestamps
    end

    create_table :additional_incomes do |t|
      t.decimal :amount, precision: 12, scale: 2
      t.integer :category
      t.string :description
      t.integer :payment_method
      t.date :date
      t.string :user_email

      t.timestamps
    end
  end
end
