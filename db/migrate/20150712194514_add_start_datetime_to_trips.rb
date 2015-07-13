class AddStartDatetimeToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :start_datetime, :datetime
  end
end
