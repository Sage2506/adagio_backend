class User < ApplicationRecord
  require "securerandom"
  has_many :lessons
  has_many :orders
  has_many :payments
  has_many :user_disciplines
  has_many :disciplines, through: :user_disciplines

  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: /@/ }
  validates :password, presence: true

  enum :role, { unasigned: 0, admin: 1, receptionis: 2, teacher: 3 }
end
