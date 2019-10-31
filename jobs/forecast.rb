require 'net/https'
require 'json'

# Forecast API Key from https://developer.forecast.io
$forecast_api_key = ENV["FORECAST_API_KEY"]


$locations = [
    { lat: 48.135124, long: 11.581981, name: "Munich"},
    { lat: 50.292961, long: 18.668930, name: "Gliwice"}
]

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
$forecast_units = "si"


def get_weather_data(lat,long,name)
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  url = "/forecast/#{$forecast_api_key}/#{lat},#{long}?units=#{$forecast_units}"
  response = http.request(Net::HTTP::Get.new(url))
  forecast = JSON.parse(response.body)  
  forecast_current_temp = forecast["currently"]["temperature"].round
  forecast_current_icon = forecast["currently"]["icon"]
  forecast_current_desc = forecast["currently"]["summary"]
  if forecast["minutely"]  # sometimes this is missing from the response.  I don't know why
    forecast_next_desc  = forecast["minutely"]["summary"]
    forecast_next_icon  = forecast["minutely"]["icon"]
  else
    puts "Did not get minutely forecast data again"
    forecast_next_desc  = "No data"
    forecast_next_icon  = ""
  end
  forecast_later_temp = forecast["hourly"]["data"][0]["temperature"].round
  forecast_later_desc   = forecast["hourly"]["summary"]
  forecast_later_icon   = forecast["hourly"]["icon"]
  send_event(name, { current_temp: "#{forecast_current_temp}&deg;", current_icon: "#{forecast_current_icon}", current_desc: "#{forecast_current_desc}", next_icon: "#{forecast_next_icon}", next_desc: "#{forecast_next_desc}", later_temp: "#{forecast_later_temp}&deg;", later_icon: "#{forecast_later_icon}", later_desc: "#{forecast_later_desc}", name: name})
end



SCHEDULER.every '5m', :first_in => 0 do |job|
  $locations.each do | location |
    get_weather_data(location[:lat], location[:long], location[:name])
end
end