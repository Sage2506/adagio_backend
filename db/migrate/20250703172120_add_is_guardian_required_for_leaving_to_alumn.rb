class AddIsGuardianRequiredForLeavingToAlumn < ActiveRecord::Migration[8.0]
  def change
    add_column :alumns, :is_guardian_required_for_leaving, :boolean, null: false, default: false
  end
end
