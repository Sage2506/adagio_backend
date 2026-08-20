class AddRegistrationCostToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :registration_cost, :float
  end
end
