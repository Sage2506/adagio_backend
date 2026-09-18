class Guardian < ApplicationRecord
  has_many :alumn_guardians, dependent: :destroy
  has_many :alumns, through: :alumn_guardians
  before_validation :downcase_all
  before_create :set_defaults
  validate :email_or_phone_number_present

  scope :oldest_first, -> { order(created_at: :asc) }

  def set_defaults
    self.is_active = true
  end

  def downcase_all
    self.name = name.downcase if name.present?
    self.last_name = last_name.downcase if last_name.present?
    self.phone_number = phone_number.downcase if phone_number.present?
    self.email = email.downcase if email.present?
  end

  def email_or_phone_number_present
    return if email.present? || phone_number.present?
    errors.add(:base, "Debe proporcionar al menos un email o un número de teléfono")
  end
end
