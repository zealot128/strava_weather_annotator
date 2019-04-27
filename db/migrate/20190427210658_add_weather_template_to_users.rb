class AddWeatherTemplateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :weather_template, :text
  end
end
