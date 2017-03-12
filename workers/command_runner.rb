require 'sidekiq'
require 'socket'
DEFAULT_SOCKET_PATH="/var/run/dokku-daemon/dokku-daemon.sock"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CommandRunner
  include Sidekiq::Worker
  def perform(command_id, command)
    logger.info "Things are happening."
    logger.info  ENV["REDIS_URL"]

    $redis = Redis.new( url: ENV["REDIS_URL"] )

    begin
      socket = UNIXSocket.new(DEFAULT_SOCKET_PATH)
      socket.puts(command)
      result = socket.gets("\n")
      $redis.set("dda:#{command_id}", result)
    rescue Exception => e
      $redis.set("dda:#{command_id}", {status: "error", message: e.message}.to_json)
    end
  end
end
