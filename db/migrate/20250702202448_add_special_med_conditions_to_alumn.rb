class AddSpecialMedConditionsToAlumn < ActiveRecord::Migration[8.0]
  def change
    add_column :alumns, :special_med_conditions, :text, null: false, default: "None"
  end
end
