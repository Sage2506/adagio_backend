class CreateAssistances < ActiveRecord::Migration[8.0]
  def change
    create_table :assistances do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :alumn, null: false, foreign_key: true

      t.timestamps
    end
  end
end
