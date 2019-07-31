#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'json'

# Super simple dashing widget for displaying your youtube channels stats
# Credit to ephigenia and jonasrosland for creating other youtube widgets that I pulled bits and pieces from
# Hugs and kisses to my loved ones.  Vote for Nader!

# Config
# ------
youtube_api_key =  ENV['YOUTUBE_API_KEY'] || 'YOUR API KEY'
youtube_channel_id = ENV['YOUTUBE_CHANNEL_KEY'] || 'YOUR CHANNEL ID'


SCHEDULER.every '1m', :first_in => 0 do |job|
    http = Net::HTTP.new("www.googleapis.com", Net::HTTP.https_default_port())
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
    response = http.request(Net::HTTP::Get.new("/youtube/v3/channels?part=statistics&id=#{youtube_channel_id}&key=#{youtube_api_key}"))

    if response.code != "200"
        puts "youtube api error (status-code: #{response.code})\n#{response.body}"
    else
    data = JSON.parse(response.body)

    send_event('youtube_subscribers', current: data["items"][0]["statistics"]["subscriberCount"])
    send_event('youtube_views', current: data["items"][0]["statistics"]["viewCount"])
    send_event('youtube_videos', current: data["items"][0]["statistics"]["videoCount"])
    
    end
end
