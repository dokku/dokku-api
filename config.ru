require './app'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV["SIDEKIQ_USER"], ENV["SIDEKIQ_PASSWORD"] ]
end

run DokkuDaemonAPI::App

map "/sidekiq" do
  run Sidekiq::Web
end
