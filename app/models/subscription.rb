class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :alumn
  before_create :set_defaults

  def set_defaults
    if plan&.subscription_duration
      self.due_date = Date.today + plan.subscription_duration.days
    else
      errors.add(:base, "Plan or subscription duration missing")
      throw(:abort) # Prevents saving if no plan/duration is set
    end
  end
end
