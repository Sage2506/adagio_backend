class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :classroom, null: false, foreign_key: true
      t.datetime :schedule
      t.integer :status

      t.timestamps
    end
  end
end
