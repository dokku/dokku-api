require 'sinatra'
require 'ap'
require "open-uri"
require 'logger'

set :logger, Logger.new(STDOUT)

get '/' do
  'Hello World' 
end
