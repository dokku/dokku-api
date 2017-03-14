require 'sinatra/base'
require 'ap'
require "open-uri"
require 'logger'
require 'socket'
require 'sidekiq'
require './workers/command_runner'
require 'securerandom'
require 'json'
require 'byebug'
Dir["./helpers/*.rb"].each {|file| require file }

module DokkuDaemonAPI
  class App < Sinatra::Base
    set :logger, Logger.new(STDOUT)
    include Helpers::ApplicationHelper

    before do
      content_type :json
      authenticate!
    end

    get '/run' do
      command_id = generate_command_id
      CommandRunner.perform_async(command_id, params[:cmd])
      {success: true, command_id: command_id}.to_json
    end

    get '/status' do
      result = redis.get("dda:#{params[:command_id]}")

      begin
        if result
          result_json = JSON.parse(result)
          {status: "success", result: result_json}.to_json
        else
          {status: "error", result: "not_ready"}.to_json
        end
      rescue Exception => e
        logger.info e
        {status: "error", message: e.message}.to_json
      end
    end
  end
end
