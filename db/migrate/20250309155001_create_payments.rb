class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :alumn, null: false, foreign_key: true
      t.float :total

      t.timestamps
    end
  end
end
