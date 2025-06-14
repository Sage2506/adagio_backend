class CreatePlanDisciplines < ActiveRecord::Migration[8.0]
  def change
    create_table :plan_disciplines do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :discipline, null: false, foreign_key: true

      t.timestamps
    end
  end
end
