require 'sidekiq'
require 'net/http'
require File.join(File.dirname(__FILE__), "..", "config", "environment")

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CallbackWorker
  include Sidekiq::Worker

  def perform(command_id)
    logger.info "[CallbackWorker] #{command_id}"

    begin
      @command = Command.get!(command_id)

      payload = @command.to_json(exclude: :result, methods: [:result_data])

      uri = URI.parse(@command.callback_url)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri, {'Content-Type' => 'application/json'})
      req.body = payload
      resp = http.request(req)
      logger.info "[CallbackWorker] Callback hit"
    rescue Exception => e
      logger.info "[CallbackWorker] Exception"
      logger.info e
    end

    return @command
  end
end
