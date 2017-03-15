module DokkuDaemonAPI
  module Helpers
    module ApplicationHelper
      def redis
        Redis.new( url: ENV["REDIS_URL"] )
      end

      def generate_command_id
        loop do
          id = SecureRandom.hex(32)
          break id unless redis.get("dda:#{id}")
        end
      end

      def authenticate!
        unless ENV["API_KEY"] == request.env["HTTP_API_KEY"] && ENV["API_SECRET"] == request.env["HTTP_API_SECRET"]
          halt 401, nil, {status: "error", message: :not_authenticated}.to_json
        end
      end
    end
  end
end
