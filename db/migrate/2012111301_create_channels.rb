class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.string  :name, :limit => 30
      t.text    :description
      t.string  :guid, :limit => 30
      t.string  :publisher_key, :limit => 50
      t.string  :status, :limit => 20
      t.string  :email, :limit => 50
      t.string  :website, :limit => 80
      t.boolean :public, :default => false
      t.timestamps
    end
    add_index :channels, :guid
    add_index :channels, :publisher_key, :unique => true
  end

  def self.down
    [:guid, :publisher_key].each do |column|
      remove_index :channels, column
    end
    drop_table :channels
  end
end
