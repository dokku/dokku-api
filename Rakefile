require './app'

namespace :keys do

  desc 'Generates a new api key'
  task :generate do
    key = Key.generate
    puts "New API key was generated"
    puts "API KEY: #{key.api_key} | API SECRET: #{key.api_secret}"
  end

  desc 'Delete an api key'
  task :delete, :api_key do |cmd, args|
    key = Key.first(api_key: args[:api_key])
    if key
      key.destroy
      puts "Key was deleted."
    else
      puts "Key not found."
    end
  end
end
