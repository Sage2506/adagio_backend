class Alumn < ApplicationRecord
  has_many :alumn_guardians
  has_many :guardians, through: :alumn_guardians
  has_many :assistances
  has_many :orders
  has_many :payments
  has_one :subscriptions
end
