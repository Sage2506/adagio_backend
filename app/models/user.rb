class User < ApplicationRecord
  require "securerandom"

  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: /@/ }
  validates :password, presence: true

  enum :role, { unasigned: 0, admin: 1, receptionis: 2, teacher: 3 }
end
