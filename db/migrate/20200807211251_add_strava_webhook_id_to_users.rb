class AddStravaWebhookIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :strava_webhook_id, :string
  end
end
