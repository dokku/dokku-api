require 'sidekiq'
require File.join(File.dirname(__FILE__), "..", "config", "environment")
DEFAULT_SOCKET_PATH="/var/run/dokku-daemon/dokku-daemon.sock"
DEFAULT_TIMEOUT=60
Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CommandRunner
  include Sidekiq::Worker
  def perform(command_id)
    logger.info "[CommandRunner] #{command_id}"

    begin
      @command = Command.get!(command_id)
      Timeout.timeout(DEFAULT_TIMEOUT) do
        socket = UNIXSocket.new(DEFAULT_SOCKET_PATH)
        sleep(1) # Give socket 1 sec
        logger.info "[CommandRunner] Sending the command"
        socket.puts(@command.command)
        logger.info "[CommandRunner] Waiting for the result"
        result = socket.gets("\n")
        logger.info "[CommandRunner] Result: #{result}"
        @command.result = result
        @command.save!
        socket.close
      end
    rescue Timeout::Error
      logger.info "[CommandRunner] Command Timed Out"
      @command.result = {ok: false, output: "command_timed_out"}.to_json.to_s
      @command.save
      socket.close if defined? socket
    rescue Exception => e
      logger.info "[CommandRunner] Exception"
      logger.info e
      @command.result = {ok: false, output: e.message}.to_json.to_s
      @command.save
      socket.close if defined? socket
    end
  end
end
