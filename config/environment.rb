require 'rubygems'
require 'bundler/setup'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-migrations'
require 'dm-serializer'

require 'ap'
require 'sidekiq'
require 'securerandom'
require 'json'
require 'byebug'
require 'sinatra' unless defined?(Sinatra)


configure do

  Dir.glob("#{File.dirname(__FILE__)}/../helpers/*.rb") { |f| require f }
  Dir.glob("#{File.dirname(__FILE__)}/../workers/*.rb") { |f| require f }
  Dir.glob("#{File.dirname(__FILE__)}/../models/*.rb") { |f| require f }

  DataMapper.setup(:default, ENV["DATABASE_URL"] || 'postgres://localhost/dokkuapi')
  DataMapper.finalize
  DataMapper.auto_upgrade!
end
