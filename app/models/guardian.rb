class Guardian < ApplicationRecord
  has_many :alumn_guardians
  has_many :alumns, through: :alumn_guardians
end
