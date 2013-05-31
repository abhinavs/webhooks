class Notification < ActiveRecord::Base
  include Webhooks::Record

  PROCESSED = 'processed'
  PENDING   = 'pending'
  FAILED    = 'failed'

  validates_presence_of :status, :webhook_id, :webhook_url
  validates_length_of   :webhook_url, :maximum => 255
  validates_format_of   :webhook_url, :with => URI::regexp(%w(http https))

  attr_protected  :event_id, :http_code, :error, :error_message,
                  :status, :created_at, :updated_at

  belongs_to  :event
  belongs_to  :webhook

  before_validation :set_default_values, :on => :create
  after_create :async_call_webhook_url

  def call_webhook_url
    response = RestClient.post(webhook.webhook_url, event.to_json)
    save_attributes!(:status => PROCESSED, :http_code => response.code)
  rescue RestClient::Exception => e
    save_attributes!(:status => FAILED, :error => true,
      :error_message => e.message, :http_code => e.http_code, :number_of_retries => number_of_retries + 1)
    raise e
  end

  def save_attributes!(attrs)
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
    save!
  end

  private

  def set_default_values
    write_attribute(:status, PENDING) if status.blank?
    write_attribute(:number_of_retries, 0)
    write_attribute(:error, false)
    true # because last thing we do is write false value
  end

  def async_call_webhook_url
    delay.call_webhook_url
  end

end

# == Schema Information
#
# Table name: notifications
#
#  id            :integer          not null, primary key
#  event_id      :integer          indexed
#  webhook_id    :integer          indexed
#  http_code     :integer
#  error_message :text
#  error         :boolean
#  status        :string(20)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#


