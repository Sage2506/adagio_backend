class AddDisciplineToLesson < ActiveRecord::Migration[8.0]
  def change
    add_reference :lessons, :discipline, null: false, foreign_key: true
  end
end
