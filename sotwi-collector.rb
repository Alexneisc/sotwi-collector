require 'twitter'
require 'sidekiq'
require 'active_support/core_ext/time/calculations'
require 'telegram/bot'
require_relative 'config/twitter.rb'
require_relative 'config/sidekiq.rb'
require_relative 'config/telegram.rb'

class NewTweetWorker
  include Sidekiq::Worker
end

begin
  if TELEGRAM_ON
    text = "Collector started\n"
    text += "Server time: #{Time.current}"

    TELEGRAM_BOT.api.send_message(chat_id: TELEGRAM_CHAT_ID, text: text)
  end

  TWITTER_CLIENT.filter(track: TWITTER_TOPIC.join(',')) do |tweet|
    # puts "ID: #{tweet.id}"
    # puts "USER ID: #{tweet.user.id}"
    # puts "USER NAME: #{tweet.user.name}"
    # puts "USER SCREEN NAME: #{tweet.user.screen_name}"
    # puts "TEXT: #{tweet.text}"
    # puts "FULL TEXT: #{tweet.full_text}"
    # puts "CREATED AT: #{tweet.created_at}"
    # puts "CURRENT TIME: #{Time.current}"
    # puts "retweet?: #{tweet.retweet?}"
    # puts "retweeted_tweet: #{tweet.retweeted_tweet.id}"
    # puts "TAGS: #{tweet.hashtags.map(&:text).join(',')}"
    # puts '========'
    # puts "RETWEETED USER ID: #{tweet.retweeted_tweet.user.id}"
    # puts "RETWEETED USER NAME: #{tweet.retweeted_tweet.user.name}"
    # puts "RETWEETED USER SCREEN NAME: #{tweet.retweeted_tweet.user.screen_name}"
    # puts "RETWEETED FULL TEXT: #{tweet.retweeted_tweet.full_text}"
    # puts "RETWEETED CREATED AT: #{tweet.retweeted_tweet.created_at}"
    # puts "RETWEETED TAGS: #{tweet.retweeted_tweet.hashtags.map(&:text).join(',')}"
    # puts '-----------------------------------'

    NewTweetWorker.perform_async(
      Time.current,
      tweet_data = {
        'id': tweet.id,
        'text': tweet.full_text,
        'user_id': tweet.user.id,
        'user_name': tweet.user.name,
        'user_screen_name': tweet.user.screen_name,
        'created_at': tweet.created_at,
        'is_retweet': tweet.retweet?,
        'tags': tweet.hashtags.map(&:text).join(','),
      },
      retweet_data = {
        'id': tweet.retweeted_tweet.id,
        'text': tweet.retweeted_tweet.full_text,
        'user_id': tweet.retweeted_tweet.user.id,
        'user_name': tweet.retweeted_tweet.user.name,
        'user_screen_name': tweet.retweeted_tweet.user.screen_name,
        'created_at': tweet.retweeted_tweet.created_at,
        'is_retweet': tweet.retweet?,
        'tags': tweet.retweeted_tweet.hashtags.map(&:text).join(','),
      }
    )
  end
rescue ::Twitter::Error::TooManyRequests => e
  text = "Collector stopped working\n"
  text += "'TooManyRequests'\n"
  text += "#{e.inspect}\n"
  text += "#{e.rate_limit.inspect}\n"
  text += "#{e.rate_limit.limit}\n"
  text += "#{e.rate_limit.remaining}\n"
  text += "#{e.rate_limit.reset_at}\n"
  text += "#{e.rate_limit.reset_in}\n"
  text += "Server time: #{Time.current}"

  # puts text

  if TELEGRAM_ON
    TELEGRAM_BOT.api.send_message(chat_id: TELEGRAM_CHAT_ID, text: text)
  end

  sleep e.rate_limit.reset_in + 1
  retry
rescue Exception => e
  text = "Collector stopped working\n"
  text += "'Exception'\n"
  text += "Message:\n"
  text += "#{e.message}\n"
  text += "Server time: #{Time.current}"

  # puts text

  if TELEGRAM_ON
    TELEGRAM_BOT.api.send_message(chat_id: TELEGRAM_CHAT_ID, text: text)
  end
end
