class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :channel_id
      t.string  :event_url
      t.string  :event_name, :limit => 30
      t.string  :event_reference_id, :limit => 30
      t.text    :data
      t.string  :status, :limit => 20
      t.timestamps
    end
    add_index :events, :channel_id
  end

  def self.down
    remove_index :events, :channel_id
    drop_table :events
  end
end
