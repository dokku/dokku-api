web: puma -C config/puma.rb
worker: sidekiq -r ./workers/command_runner.rb -C ./config/sidekiq.yml
