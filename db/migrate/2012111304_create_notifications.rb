class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :event_id
      t.integer :webhook_id
      t.integer :http_code
      t.string  :error_message
      t.boolean :error
      t.string  :status, :limit => 20
      t.integer :number_of_retries
      t.string  :webhook_url
      t.timestamps
    end
    [:event_id, :webhook_id].each do |column|
      add_index :notifications, column
    end
  end

  def self.down
    [:event_id, :webhook_id].each do |column|
      remove_index :notifications, column
    end
    drop_table :notifications
  end
end
