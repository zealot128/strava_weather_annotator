class CreateTripStreams < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_streams do |t|
      t.belongs_to :trip, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
