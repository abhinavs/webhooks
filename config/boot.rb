ENV['APP_ENV'] ||= 'development'

def require_local_lib(path)
  Dir["#{File.dirname(__FILE__)}/#{path}/*.rb"].each {|f| require f }
end

require 'rubygems'
require 'yaml'
Configuration = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

require 'bundler'
require 'logger'
require 'sinatra'
require 'active_record'
require 'json'
require 'rack/throttle'
require 'restclient'
require 'delayed_job_active_record'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/hash/slice'

require "#{File.dirname(__FILE__)}/database"
require_local_lib('../library')
require_local_lib('../models')

#sum = 0; 1.upto(13) { |i| sum = sum + (5 + i ** 4)/3600.0 }; sum
Delayed::Worker.max_attempts = 13 # retry for ~24 hours
