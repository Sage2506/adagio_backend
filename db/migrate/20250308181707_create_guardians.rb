class CreateGuardians < ActiveRecord::Migration[8.0]
  def change
    create_table :guardians do |t|
      t.string :name
      t.string :last_name
      t.text :address
      t.string :phone_number
      t.string :email
      t.boolean :is_active

      t.timestamps
    end
  end
end
