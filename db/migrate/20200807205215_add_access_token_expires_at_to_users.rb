class AddAccessTokenExpiresAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :access_token_expires_at, :datetime
  end
end
