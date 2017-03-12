web: bundle exec rackup config.ru -p $PORT
worker: bundle exec sidekiq -r ./workers/command_runner.rb -C ./config/sidekiq.yml
