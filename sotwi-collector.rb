# require 'sinatra'
require 'twitter'
require 'sidekiq'
# require 'sinatra/activerecord'
require 'active_support/core_ext/time/calculations'
require_relative 'config/twitter.rb'
require_relative 'config/sidekiq.rb'

# project_root = File.dirname(File.absolute_path(__FILE__))
# Dir.glob(project_root + '/models/*.rb').each{|f| require_relative f}

class NewTweetWorker
  include Sidekiq::Worker
end

begin
  TWITTER_CLIENT.filter(track: TWITTER_TOPIC) do |tweet|
    puts "ID: #{tweet.id}"
    puts "USER ID: #{tweet.user.id}"
    puts "USER NAME: #{tweet.user.name}"
    puts "USER SCREEN NAME: #{tweet.user.screen_name}"
    puts "TEXT: #{tweet.text}"
    puts "CURRENT TIME: #{Time.current}"
    puts '-----------------------------------'

    NewTweetWorker.perform_async(
      tweet.id,
      tweet.text,
      tweet.user.id,
      tweet.user.name,
      tweet.user.screen_name,
      Time.current
    )

  end
rescue ::Twitter::Error::TooManyRequests => e
  puts "Oh shit here come data error #{e.inspect}"
  puts e.rate_limit.inspect
  puts e.rate_limit.limit
  puts e.rate_limit.remaining
  puts e.rate_limit.reset_at
  puts e.rate_limit.reset_in
  raise e
end
