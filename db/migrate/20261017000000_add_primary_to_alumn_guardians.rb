class AddPrimaryToAlumnGuardians < ActiveRecord::Migration[8.1]
  def change
    add_column :alumn_guardians, :primary, :boolean, default: false, null: false
    add_index :alumn_guardians, :alumn_id,
      unique: true,
      where: "\"primary\" = true",
      name: "index_alumn_guardians_on_alumn_id_primary"
  end
end
