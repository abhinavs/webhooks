class Webhook < ActiveRecord::Base
  include Webhooks::Record
  extend Webhooks::KeyGenerator

  DELETED = 'deleted'
  ACTIVE  = 'active'

  validates_presence_of   :name, :webhook_url, :subscriber_key
  validates_uniqueness_of :subscriber_key
  validates_length_of     :name, :maximum => 30
  validates_length_of     :webhook_url, :maximum => 255
  validates_format_of     :webhook_url, :with => URI::regexp(%w(http https))

  belongs_to  :channel
  has_many    :notifications

  before_validation :set_default_values, :on => :create

  attr_protected :channel_id, :subscriber_key, :status, :created_at, :updated_at

  scope :by_channel_id_and_webhook_id, lambda { |channel_id, webhook_id|
    where("channel_id = ? AND id = ? AND status != ?",
    channel_id, webhook_id, DELETED) }

  def self.accessible_keys
    ['name', 'webhook_url']
  end

  def self.get_by_channel_id_and_webhook_id(ch_id, webhook_id)
    self.by_channel_id_and_webhook_id(ch_id, webhook_id).first
  end

  def authorized?(key)
    key == subscriber_key
  end

  def mark_as_deleted
    update_attributes!(:status => DELETED)
  end

  private

  def set_default_values
    write_attribute(:subscriber_key, "sk_#{self.generate_key}")
    write_attribute(:status, ACTIVE)
  end

end

# == Schema Information
#
# Table name: webhooks
#
#  id             :integer          not null, primary key
#  channel_id     :integer          indexed
#  webhook_url    :string(255)
#  subscriber_key :string(50)       indexed
#  name           :string(30)
#  status         :string(20)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

