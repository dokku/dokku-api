require './app'
require 'sidekiq/web'
run Sinatra::Application

map "/sidekiq" do
  run Sidekiq::Web
end
