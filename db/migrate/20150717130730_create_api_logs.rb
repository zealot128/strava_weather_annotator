class CreateApiLogs < ActiveRecord::Migration
  def change
    create_table :api_logs do |t|
      t.belongs_to :user
      t.string :title
      t.string :provider
      t.date :date


      t.timestamps null: false
    end
    add_index :api_logs, [:user_id, :date, :provider]
  end
end
