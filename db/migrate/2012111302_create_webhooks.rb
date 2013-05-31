class CreateWebhooks < ActiveRecord::Migration
  def self.up
    create_table :webhooks do |t|
      t.integer :channel_id
      t.string  :webhook_url
      t.string  :subscriber_key, :limit => 50
      t.string  :name, :limit => 30
      t.string  :status, :limit => 20
      t.timestamps
    end
    add_index :webhooks, :channel_id
    add_index :webhooks, :subscriber_key, :unique => true
  end

  def self.down
    [:channel_id, :subscriber_key].each do |column|
      remove_index :webhooks, column
    end
    drop_table :webhooks
  end
end
