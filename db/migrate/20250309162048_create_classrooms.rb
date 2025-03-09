class CreateClassrooms < ActiveRecord::Migration[8.0]
  def change
    create_table :classrooms do |t|
      t.string :name
      t.string :description
      t.boolean :is_active

      t.timestamps
    end
  end
end
