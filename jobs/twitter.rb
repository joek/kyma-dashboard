require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET_KEY"]
  config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

SCHEDULER.every '15m', :first_in => 0 do |job|
  user_name = ENV['TWITTER_USER']
  begin
    user = twitter.user(user_name)
    
    if twitter.mentions
      mentions = twitter.user_timeline(user_name).map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', {comments: mentions, moreinfo: "Twitter User: @#{user.screen_name}"})
    end    
    send_event('twitter_followers', {current: user.followers_count})
    send_event('twitter_tweets', {current: user.statuses_count})
  rescue Twitter::Error
    puts "\e[33mThere was an error with Twitter\e[0m"
  end

end

