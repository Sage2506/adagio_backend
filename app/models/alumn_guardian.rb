class AlumnGuardian < ApplicationRecord
  belongs_to :alumn
  belongs_to :guardian

  validates :primary, uniqueness: { scope: :alumn_id }, if: :primary?

  # Marks this link as the alumn's only primary guardian.
  def make_primary!
    transaction do
      AlumnGuardian.where(alumn_id: alumn_id, primary: true).where.not(id: id).update_all(primary: false)
      update!(primary: true)
    end
  end
end
