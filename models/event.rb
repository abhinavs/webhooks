class Event < ActiveRecord::Base
  include Webhooks::Record

  PROCESSED = 'processed'
  PENDING   = 'pending'

  validates_presence_of   :event_name, :data
  validates_format_of     :event_url, :with => URI::regexp(%w(http https)), :allow_nil => true
  validates_length_of     :event_name, :maximum => 30
  validates_length_of     :event_reference_id, :maximum => 30, :allow_nil => true

  attr_protected  :channel_id, :status, :created_at, :updated_at

  belongs_to  :channel
  has_many    :notifications

  before_validation :set_default_values, :on => :create
  after_create :async_create_notifications

  def self.accessible_keys
    ['event_name', 'event_url', 'event_reference_id', 'data']
  end

  def create_notifications
    channel.webhooks.each do |webhook|
      self.notifications.create("webhook_id" => webhook.id, "webhook_url" => webhook.webhook_url)
    end
    self.status = PROCESSED
    save!
  end

  private

  def set_default_values
    write_attribute(:status, PENDING) if status.blank?
  end

  def async_create_notifications
    delay.create_notifications
  end

end

# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  channel_id :integer          indexed
#  event_url  :string(255)
#  event_name :string(30)
#  event_id   :string(30)
#  data       :text
#  status     :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


