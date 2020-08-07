class CreateStravaWebhookEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :strava_webhook_events do |t|
      t.belongs_to :user, foreign_key: true
      t.string :object_type
      t.string :object_id
      t.string :aspect_type
      t.jsonb :updates
      t.string :owner_id
      t.integer :subscription_id
      t.datetime :event_type

      t.timestamps
    end
  end
end
