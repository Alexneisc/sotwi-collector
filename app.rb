require 'sinatra'
require 'twitter'
require 'sinatra/activerecord'
require_relative 'config/twitter.rb'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/models/*.rb').each{|f| require_relative f}

get '/' do
  "I'm Sotwi!"
end

begin
  TWITTER_CLIENT.filter(track: TWITTER_TOPIC) do |tweet|
    Tweet.check_and_create(
      tweet.id,
      tweet.text,
      tweet.user.id,
      tweet.user.name,
      tweet.user.screen_name
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
