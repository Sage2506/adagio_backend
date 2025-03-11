class Discipline < ApplicationRecord
  has_many :plan_disciplines
  has_many :plans, through: :plan_disciplines
  has_many :user_disciplines
  has_many :users, through: :user_disciplines
  has_many :lessons
end
