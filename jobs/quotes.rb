#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'json'


SCHEDULER.every '60m', :first_in => 0 do |job|
  http = Net::HTTP.new("corporatebs-generator.sameerkumar.website", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
  response = http.request(Net::HTTP::Get.new("/"))
  data = JSON.parse(response.body)

  if response.code != "200"
    puts "corporatebs api error (status-code: #{response.code})\n#{response.body}"
  else
    send_event('ken_quote', { text: data["phrase"] })

  end # if

end # SCHEDULER