class CreateAlumnGuardians < ActiveRecord::Migration[8.0]
  def change
    create_table :alumn_guardians do |t|
      t.references :alumn, null: false, foreign_key: true
      t.references :guardian, null: false, foreign_key: true

      t.timestamps
    end
  end
end
