class Discipline < ApplicationRecord
  has_many :plan_disciplines
  has_many :plans, through: :plan_disciplines
  has_many :user_disciplines
  has_many :users, through: :user_disciplines
  has_many :lessons
  scope :active, -> { where(is_active: true) }

  before_create :set_defaults

  def set_defaults
    self.is_active = true if is_active.nil?
  end
end
