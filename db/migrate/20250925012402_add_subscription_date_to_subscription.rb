class AddSubscriptionDateToSubscription < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :subscribed_at, :datetime
  end
end
