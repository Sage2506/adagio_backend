class SubscriptionPayment < ApplicationRecord
  belongs_to :subscription
  belongs_to :payment

  after_create :update_subscription_status

  private
  def update_subscription_status
    subscription.update!(
      last_payment_date: Time.current,
      status: :active
    )
  end
end
