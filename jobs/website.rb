require 'twitter'
require 'googleauth'
require 'google/apis/analytics_v3'

scopes =  ['https://www.googleapis.com/auth/analytics.readonly',
  'https://www.googleapis.com/auth/analytics']

auth = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(ENV["GOOGLE_API_KEY"]),
  scope: scopes)




SCHEDULER.every '15m', :first_in => 0 do |job|  
  analytics = Google::Apis::AnalyticsV3::AnalyticsService.new
  analytics.authorization = auth

  dimensions = %w(ga:date)
  metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
               ga:sessionDuration ga:avgSessionDuration)
  sort = %w(ga:date)
  result = analytics.get_ga_data("ga:178902064",
                                 "2019-01-01",
                                 "2019-02-01",
                                 metrics.join(','),
                                 dimensions: dimensions.join(','),
                                 sort: sort.join(','))

  data = []
  data.push(result.column_headers.map { |h| h.name })
  data.push(*result.rows)

end

