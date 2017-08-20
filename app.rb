require 'sinatra'
require 'twitter'
require 'sinatra/activerecord'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/models/*.rb').each{|f| require_relative f}
Dir.glob(project_root + '/config/*.rb').each{|f| require_relative f}

# get '/' do
#   "I'm Sotwi!"
# end
#
# client = Twitter::Streaming::Client.new do |config|
#   config.consumer_key        = "PiPaefX8EkMbhtuEECzLvuSZC"
#   config.consumer_secret     = "8f2LYKRLnE6y27XrdpXN8aTNhIlN77hii415d9bKmRVNAp1Wpe"
#   config.access_token        = "1074779419-Jin5CFs7uE9ZzWfM4Jp70KLkKMfYuyZK17a5l0N"
#   config.access_token_secret = "AypQKSAM7S7eCQknLq3MtYLubT6YKaCiwPdgt0YFq2etv"
# end

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
