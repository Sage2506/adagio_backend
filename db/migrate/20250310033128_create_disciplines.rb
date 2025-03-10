class CreateDisciplines < ActiveRecord::Migration[8.0]
  def change
    create_table :disciplines do |t|
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
  end
end
