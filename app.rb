require "rubygems"
require "bundler/setup"
require "sinatra"
require File.join(File.dirname(__FILE__), "config", "environment")


module DokkuDaemonAPI
  class App < Sinatra::Base
    set :logger, Logger.new(STDOUT)
    include Helpers::ApplicationHelper

    before do
      content_type :json
      authenticate!
    end

    get '/commands' do
      Command.all.to_json(exclude: :result, methods: [:result_data])
    end

    post '/commands' do
      command = Command.create(command: params[:cmd], callback_url: params[:callback_url])
      run_sync = params[:sync] == "true"
      callback = params[:callback] == "true"

      if command.valid?
        if run_sync
          @result = CommandRunner.new.perform(command.id)
          return @result.to_json(exclude: :result, methods: [:result_data])
        else
          CommandRunner.perform_async(command.id)
          return command.to_json(exclude: :result, methods: [:result_data])
        end
      else
        status 422
        return {status: :error, messages: command.errors.collect{|field,msg| "#{field} #{msg}"}}.to_json
      end
    end

    get '/commands/:token' do
      command = Command.first(token: params[:token])

      if command
        command.to_json(exclude: :result, methods: [:result_data])
      else
        status 404
        {status: :error, message: :not_found}.to_json
      end
    end

    get '/commands/:token/retry' do
      command = Command.first(token: params[:token])

      if command
        CommandRunner.perform_async(command.id)
        command.update!(result: nil)
        command.to_json(exclude: :result, methods: [:result_data])
      else
        status 404
        {status: :error, message: :not_found}.to_json
      end
    end
  end
end
