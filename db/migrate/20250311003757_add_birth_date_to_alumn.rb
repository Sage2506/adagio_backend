class AddBirthDateToAlumn < ActiveRecord::Migration[8.0]
  def change
    add_column :alumns, :birth_date, :date
  end
end
