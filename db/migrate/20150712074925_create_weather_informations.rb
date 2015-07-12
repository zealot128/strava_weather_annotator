class CreateWeatherInformations < ActiveRecord::Migration
  def change
    create_table :weather_informations do |t|
      t.belongs_to :trip, index: true, foreign_key: true
      t.integer :offset
      t.datetime :datetime
      t.json :data
      t.float :lat
      t.float :lon

      t.timestamps null: false
    end
  end
end
