require './app'
require 'sidekiq/web'
run DokkuDaemonAPI::App

map "/sidekiq" do
  run Sidekiq::Web
end
