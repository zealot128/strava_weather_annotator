class AddWeatherEnqueuedToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :weather_enqueued_on, :datetime
  end
end
