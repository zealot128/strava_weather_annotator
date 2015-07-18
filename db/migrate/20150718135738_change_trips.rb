class ChangeTrips < ActiveRecord::Migration
  def change
    change_table :trips do |t|
      t.string :temperature
      t.string :icon
      t.boolean :commented_posted
    end
  end
end
