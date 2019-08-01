#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'json'
require 'uri'

monitoring_url = URI(ENV['MONITORING_URL'])

SCHEDULER.every '15m', :first_in => 0 do |job|
    all_uri = monitoring_url.clone
    all_uri.query = URI.encode_www_form({query: 'sum(prowjobs{state="success"} or prowjobs * 0) / (sum(prowjobs{state="failure"} or prowjobs * 0) + sum(prowjobs{state="success"} or prowjobs * 0))'})
    all = get_data(all_uri)
    send_event('prow_success_rate', {current: (all.to_f * 100).round(2) })
    post_url = monitoring_url.clone
    post_url.query = URI.encode_www_form({query: 'sum(prowjobs{state="success", type="postsubmit"} or prowjobs * 0) / (sum(prowjobs{state="failure", type="postsubmit"} or prowjobs * 0) + sum(prowjobs{state="success", type="postsubmit"} or prowjobs * 0))'})
    post = get_data(post_url)
    send_event('prow_success_rate_post', {current: (post.to_f * 100).round(2) })
    pre_url = monitoring_url.clone
    pre_url.query = URI.encode_www_form({query: 'sum(prowjobs{state="success", type="presubmit"} or prowjobs * 0) / (sum(prowjobs{state="failure", type="presubmit"} or prowjobs * 0) + sum(prowjobs{state="success", type="presubmit"} or prowjobs * 0))'})
    pre = get_data(pre_url)
    send_event('prow_success_rate_pre', {current: (pre.to_f * 100).round(2) })
    perodic_url = monitoring_url.clone
    perodic_url.query = URI.encode_www_form({query: 'sum(prowjobs{state="success", type="periodic"} or prowjobs * 0) / (sum(prowjobs{state="failure", type="periodic"} or prowjobs * 0) + sum(prowjobs{state="success", type="periodic"} or prowjobs * 0))'})
    periodic = get_data(perodic_url)
    send_event('prow_success_rate_periodic', {current: (periodic.to_f * 100).round(2) })

    


end # SCHEDULER


def get_data(uri)
    response = Net::HTTP.get(uri)
    d = JSON.parse(response)
    return d['data']['result'][0]['value'][1]
    
end
