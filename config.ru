require 'rubygems'
require File.join(File.dirname(__FILE__), 'webhooks')
set :environment, ENV['APP_ENV'].to_sym
run Webhooks::Application
