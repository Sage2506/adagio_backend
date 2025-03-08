class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :last_name, null: false
      t.string :phone_number
      t.string :email, null: false
      t.text :address
      t.integer :role, null: false, default: 0
      t.string :password_digest
      t.boolean :is_active, null: false, default: :true

      t.timestamps
    end
  end
end
