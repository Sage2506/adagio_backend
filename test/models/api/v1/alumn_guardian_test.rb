require "test_helper"

class Api::V1::AlumnGuardianTest < ActiveSupport::TestCase
  test "primary defaults to false" do
    assert_not AlumnGuardian.new.primary
  end

  test "make_primary! leaves a single primary guardian per alumn" do
    alumn = alumns(:one)
    other_guardian = Guardian.create!(name: "otra", email: "otra@example.com")
    alumn.guardians << other_guardian
    first_link = alumn.alumn_guardians.find_by!(guardian_id: guardians(:one).id)
    second_link = alumn.alumn_guardians.find_by!(guardian_id: other_guardian.id)

    first_link.make_primary!
    second_link.make_primary!

    assert_not first_link.reload.primary
    assert second_link.reload.primary
  end

  test "does not allow two primary guardians for the same alumn" do
    alumn = alumns(:one)
    other_guardian = Guardian.create!(name: "otra", email: "otra@example.com")
    alumn.guardians << other_guardian
    alumn.alumn_guardians.find_by!(guardian_id: guardians(:one).id).update!(primary: true)

    duplicate = alumn.alumn_guardians.find_by!(guardian_id: other_guardian.id)
    duplicate.primary = true

    assert_not duplicate.valid?
  end
end
