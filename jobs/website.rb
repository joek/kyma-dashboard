require 'googleauth'
require 'google/apis/analyticsreporting_v4'






SCHEDULER.every '60m', :first_in => 0 do |job|  
  current_users = user_count(Google::Apis::AnalyticsreportingV4::DateRange.new(start_date: '30DaysAgo', end_date: 'yesterday'))
  last_users = user_count(Google::Apis::AnalyticsreportingV4::DateRange.new(start_date: '60DaysAgo', end_date: '30DaysAgo'))

  puts current_users
  puts last_users

end

def user_count(date_range)
  scopes =  ['https://www.googleapis.com/auth/analytics.readonly',
    'https://www.googleapis.com/auth/analytics']
  
  auth = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(ENV["GOOGLE_API_KEY"]),
    scope: scopes)
  analytics = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
  analytics.authorization = auth

  metric = Google::Apis::AnalyticsreportingV4::Metric.new(expression: 'ga:users')
  
  dimension = Google::Apis::AnalyticsreportingV4::Dimension.new(name: 'ga:userType')

  request = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
    report_requests: [Google::Apis::AnalyticsreportingV4::ReportRequest.new(
      view_id: ENV['PAGE_ID'],
      metrics: [metric],
      dimensions: [dimension],
      date_ranges: [date_range]
    )]
  ) 

  response = analytics.batch_get_reports(request)

  new_visitors = 0
  returning_visitors = 0

  response.reports[0].data.rows.each do |row|
    case row.dimensions[0]
    when "New Visitor"
      new_visitors = row.metrics[0].values[0]
    when "Returning Visitor"
      returning_visitors = row.metrics[0].values[0]
    end
  end

  return [new_visitors, returning_visitors]
end

