require 'googleauth'
require 'google/apis/analyticsreporting_v4'






SCHEDULER.every '60m', :first_in => 0 do |job|  
  scopes =  ['https://www.googleapis.com/auth/analytics.readonly',
    'https://www.googleapis.com/auth/analytics']

  auth = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(ENV["GOOGLE_API_KEY"]),
    scope: scopes)
  analytics = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
  analytics.authorization = auth

  current = Google::Apis::AnalyticsreportingV4::DateRange.new(start_date: '30DaysAgo', end_date: 'yesterday')
  last = Google::Apis::AnalyticsreportingV4::DateRange.new(start_date: '60DaysAgo', end_date: '30DaysAgo')
  
  current_users = user_count(analytics, current)
  last_users = user_count(analytics, last)

  current_duration = user_duration(analytics, current)
  last_duration = user_duration(analytics, last)

  puts current_users
  puts last_users
  puts current_duration
  puts last_duration
end

def user_count(analytics, date_range)
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

def user_duration(analytics, date_range)
  metric = Google::Apis::AnalyticsreportingV4::Metric.new(expression: 'ga:avgSessionDuration')

  request = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
    report_requests: [Google::Apis::AnalyticsreportingV4::ReportRequest.new(
      view_id: ENV['PAGE_ID'],
      metrics: [metric],
      date_ranges: [date_range]
    )]
  ) 

  response = analytics.batch_get_reports(request)

  return (response.reports[0].data.rows[0].metrics[0].values[0].to_f / 60).round(2)
end

