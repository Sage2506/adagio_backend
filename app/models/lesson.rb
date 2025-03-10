class Lesson < ApplicationRecord
  belongs_to :plan
  belongs_to :user
  belongs_to :classroom
end
