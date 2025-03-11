class Plan < ApplicationRecord
  has_many :plan_disciplines
  has_many :plans, through: :plan_disciplines
  has_many :subscriptions
end
