require "test_helper"

class Api::V1::AlumnTest < ActiveSupport::TestCase
  test "between_ages includes both age boundaries" do
    travel_to Date.new(2026, 9, 21) do
      four_year_old = create_alumn("four", Date.new(2022, 9, 21))
      eight_year_old = create_alumn("eight", Date.new(2018, 9, 21))
      too_young = create_alumn("young", Date.new(2022, 9, 22))
      too_old = create_alumn("old", Date.new(2017, 9, 21))

      result_ids = Alumn.between_ages("4", "8").where(id: [ four_year_old, eight_year_old, too_young, too_old ]).ids

      assert_includes result_ids, four_year_old.id
      assert_includes result_ids, eight_year_old.id
      assert_not_includes result_ids, too_young.id
      assert_not_includes result_ids, too_old.id
    end
  end

  private
  def create_alumn(name, birth_date)
    Alumn.create!(name: name, last_name: "filter", email: "#{name}@example.com", birth_date: birth_date)
  end
end
