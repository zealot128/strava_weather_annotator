class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name
      t.string :date
      t.text :description
      t.string :link
      t.string :strava_id

      t.timestamps null: false
    end
  end
end
