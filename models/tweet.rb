class Tweet < ActiveRecord::Base

  def self.check_and_create(tw_id, unformatted_text, user_id, user_name, user_screen_name)
    # RT @SalamaChiroWS: We couldn't resist sharing! #LOL https://t.co/C5VYZ0w53a

    text = unformatted_text.gsub(/^RT @(.+?): /, '').gsub(/#{TWITTER_TOPIC}/i, '').strip

    # Check for one tweet from one user
    # unless Tweet.find_by(text: text, user_screen_name: user_screen_name)
    #   Tweet.create(tw_id: tw_id, user_screen_name: user_screen_name, text: text)
    # end

    Tweet.create(
      tw_id: tw_id,
      user_id: user_id,
      user_name: user_name,
      user_screen_name: user_screen_name,
      text: text
    )
  end
end
