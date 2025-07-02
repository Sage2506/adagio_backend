class Guardian < ApplicationRecord
  has_many :alumn_guardians
  has_many :alumns, through: :alumn_guardians

  before_create :set_defaults

  def set_defaults
    self.is_active = true
  end
end
