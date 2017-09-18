require 'twitter'
require 'sidekiq'
require 'active_support/core_ext/time/calculations'
require_relative 'config/twitter.rb'
require_relative 'config/sidekiq.rb'

class NewTweetWorker
  include Sidekiq::Worker
end

telegram_bot = Telegram::Bot::Client.new(TELEGRAM_TOKEN)

telegram_bot.api.send_message(chat_id: TELEGRAM_CHAT_ID, text: 'Bot init')

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
  text = "Twitter bot stopped working\n"
  text += "#{Time.current}\n"
  text += "#{e.inspect}\n"
  text += "#{e.rate_limit.inspect}\n"
  text += "#{e.rate_limit.limit}\n"
  text += "#{e.rate_limit.remaining}\n"
  text += "#{e.rate_limit.reset_at}\n"
  text += "#{e.rate_limit.reset_in}"

  telegram_bot = Telegram::Bot::Client.new(TELEGRAM_TOKEN)

  telegram_bot.api.send_message(chat_id: TELEGRAM_CHAT_ID, text: text)
  raise e
end
