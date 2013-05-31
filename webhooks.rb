$:.<< File.dirname(__FILE__)

#curl -XPOST -d "name=xyz" -d "email=abhinav@mailinator.com" -d "public=true" http://localhost:9292/v1/channels
#curl -XPOST -d "name=xyz" -d "webhook_url=http://localhost:9292/webhook" http://localhost:9292/v1/channels/1/webhooks
#curl -XPOST -d "event_name=request.created" -d "data='{name:test@mailinator.com}'" http://localhost:9292/v1/channels/1/events

require File.join(File.dirname(__FILE__), 'config', 'boot')

module Webhooks
  class Application < Sinatra::Base

    use Rack::Throttle::Daily,    :max => 1000  # requests
    use Rack::Throttle::Hourly,   :max => 100   # requests
    #use Rack::Throttle::Interval, :min => 1   # seconds

    mime_type :json, "application/json"
    configure { set :public_folder, File.join(File.dirname(__FILE__), 'public') }
    before { content_type :json }

    helpers do

      def throw_unauthenticated_response
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, json_response(:error => "unauthorized")])
      end

      def authenticate_publisher!
        throw_unauthenticated_response unless authenticated_publisher?
      end

      def authenticate_publisher_or_subscriber!
        throw_unauthenticated_response unless authenticated_publisher?(public_check=false) ||
          authenticated_subscriber?
      end

      def authenticated_publisher?(public_check=true)
        @channel = Channel.get_by_guid_or_id(params[:id])
        return false unless @channel
        return true if public_check && @channel.public

        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        if @auth.provided? && @auth.basic? && @auth.credentials
          @channel.authorized?(@auth.username)
        else
          false
        end
      end

      def authenticated_subscriber?
        @webhook = Webhook.get_by_channel_id_and_webhook_id(params[:id], params[:webhook_id])
        return false unless @webhook

        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        if @auth.provided? && @auth.basic? && @auth.credentials
          @webhook.authorized?(@auth.username)
        else
          false
        end
      end
    end

    not_found { throw :halt, [404, json_response({:error => 'not_found'})] }

    def json_response(object)
      if object.is_a?(Array)
        object.map { |element| element.attrs }.to_json
      else
        object.to_json
      end
    end

    def valid_record(record, options={})
      options = {:status => 200, :response => record}.merge(options)
      status(options[:status])
      json_response(options[:response])
    end

    def invalid_record(record)
      throw :halt, [422, json_response(:errors => record.errors.full_messages)]
    end

    def manage_resource(resource, options={})
      raise Sinatra::NotFound unless resource
      yield(resource) if block_given?
      valid_record(resource, options)
    rescue ActiveRecord::RecordInvalid => e
      invalid_record(e.record)
    end

    get '/' do
      content_type :html
      erb :about
    end

    post '/v1/channels' do
      manage_resource Channel.new(params.slice(*Channel.accessible_keys)),
        :status => 201 do |channel|
        channel.save!
      end
    end

    get '/v1/channels/:id' do
      authenticate_publisher!
      manage_resource @channel
    end

    put '/v1/channels/:id' do
      authenticate_publisher!
      manage_resource @channel do |channel|
        attributes = params.slice(*Channel.accessible_keys).reject {|k,v| k == "guid"}
        channel.update_attributes!(attributes)
      end
    end

    delete '/v1/channels/:id' do
      authenticate_publisher!
      manage_resource @channel, :response => {"response" => "ok"} do |channel|
        channel.mark_as_deleted
      end
    end

    post '/v1/channels/:id/webhooks' do
      authenticate_publisher!
      manage_resource @channel.webhooks.build(params.slice(*Webhook.accessible_keys)),
        :status => 201 do |webhook|
        webhook.save!
      end
    end

    get '/v1/channels/:id/webhooks/:webhook_id' do
      authenticate_publisher_or_subscriber!
      manage_resource Webhook.by_channel_id_and_webhook_id(
        params['id'], params['webhook_id'])
    end

    put '/v1/channels/:id/webhooks/:webhook_id' do
      authenticate_publisher_or_subscriber!
      manage_resource Webhook.by_channel_id_and_webhook_id(
        params['id'], params['webhook_id']) do |webhook|
        webhook.update_attributes!(params.slice(*Webhook.accessible_keys))
      end
    end

    delete '/v1/channels/:id/webhooks/:webhook_id' do
      authenticate_publisher_or_subscriber!
      manage_resource Webhook.by_channel_id_and_webhook_id(
        params['id'], params['webhook_id']),
        :response => {"response" => "ok"} do |webhook|
        webhook.mark_as_deleted
      end
    end

    get '/v1/channels/:id/webhooks' do
      authenticate_publisher!
      manage_resource @channel.webhooks
    end

    post '/v1/channels/:id/events' do
      authenticate_publisher!
      manage_resource @channel.events.build(params.slice(*Event.accessible_keys)),
        :status => 201 do |event|
        event.save!
      end
    end

    get '/v1/channels/:id/events/:event_id' do
      authenticate_publisher!
      manage_resource @channel.events.find_by_id(params[:event_id])
    end

    get '/v1/channels/:id/events/:event_id/log' do
      authenticate_publisher!
      manage_resource @channel.events.find_by_id(params[:event_id]).try(:notifications)
    end
 end
end
