require 'sinatra'
require 'ap'
require "open-uri"
require 'logger'
require 'socket'
require 'sidekiq'
require './workers/command_runner'
require 'securerandom'
require 'json'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end
$redis = Redis.new( url:ENV["REDIS_URL"] )


set :logger, Logger.new(STDOUT)


get '/run' do
  content_type :json
  command_id = SecureRandom.hex(32)
  CommandRunner.perform_async(command_id, params[:cmd])
  {success: true, command_id: command_id}.to_json
end

get '/status' do
  content_type :json

  result = $redis.get("dda:#{params[:command_id]}")

  begin
    result_json = JSON.parse(result)
    {status: "ok", result: result_json}.to_json
  rescue Exception => e
    {status: "error", message: e.message}.to_json
  end
end
