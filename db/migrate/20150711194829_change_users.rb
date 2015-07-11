class ChangeUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :access_token
      t.string :profile_picture_url
    end
  end
end
