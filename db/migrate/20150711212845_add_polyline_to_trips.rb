class AddPolylineToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :polyline, :text
  end
end
