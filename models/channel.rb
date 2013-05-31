class Channel < ActiveRecord::Base
  include Webhooks::Record
  extend Webhooks::KeyGenerator

  DELETED = 'deleted'
  ACTIVE  = 'active'

  validates_presence_of   :name, :email, :publisher_key
  validates_uniqueness_of :guid, :allow_nil => true
  validates_uniqueness_of :publisher_key
  validates_length_of     :guid, :maximum => 30
  validates_length_of     :name, :maximum => 30
  validates_length_of     :description, :maximum => 255
  validates_length_of     :website, :maximum => 255
  validates_length_of     :email, :maximum => 50
  validates_format_of     :website, :with => URI::regexp(%w(http https)), :allow_nil => true
  validates_format_of     :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  has_many  :webhooks
  has_many  :events
  has_many  :notifications, :through => :event

  before_validation :set_default_values, :on => :create

  attr_protected :publisher_key, :status, :created_at, :updated_at

  scope :by_guid_or_id, lambda { |guid_or_id|
    where("(id = ? OR guid = ?) AND status != ?",
    guid_or_id, guid_or_id, DELETED) }

  def self.accessible_keys
    ['name', 'guid', 'description', 'website', 'email', 'public']
  end

  def self.get_by_guid_or_id(guid_or_id)
    self.by_guid_or_id(guid_or_id).first
  end

  def authorized?(key)
    key == publisher_key
  end

  def mark_as_deleted
    Channel.transaction do
      update_attributes!(:status => DELETED)
      Subscriber.where(:channel_id => id).update_all(:status => Subscriber::DELETED)
    end
  end

  private

  def set_default_values
    write_attribute(:publisher_key, "pk_#{self.generate_key}")
    write_attribute(:status, ACTIVE)
  end

end

# == Schema Information
#
# Table name: channels
#
#  id            :integer          not null, primary key
#  name          :string(30)
#  description   :text
#  guid          :string(30)       indexed
#  publisher_key :string(50)       indexed
#  status        :string(20)
#  email         :string(50)
#  website       :string(80)
#  public        :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

