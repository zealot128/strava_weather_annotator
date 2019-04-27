class AddWeatherCommentAddedToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :weather_comment_added, :boolean, default: false
  end
end
