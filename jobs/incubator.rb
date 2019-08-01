#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'json'

# This job can track metrics of a public visible user or organisation’s repos
# by using the public api of github.
# 
# Note that this API only allows 60 requests per hour.
# 
# This Job should use the `List` widget

# Config
# ------
# example for tracking single user repositories
# github_username = 'users/ephigenia'
# example for tracking an organisations repositories
github_username = ENV['GITHUB_REPOS_KYMA_INCUBATOR'] || 'orgs/foobugs'
# number of repositories to display in the list
max_length = 6
# order the list by the numbers
ordered = true

SCHEDULER.every '15m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.github.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
  response = http.request(Net::HTTP::Get.new("/#{github_username}/repos"))
  data = JSON.parse(response.body)

  if response.code != "200"
    puts "github api error (status-code: #{response.code})\n#{response.body}"
  else
    repos = Array.new
    data.each do |repo|
      repos.push({
        label: repo['name'],
        watch: repo['watchers'],
        star: repo['stargazers_count'],
        fork: repo['forks']
      })
    end

    if ordered
        repos = repos.sort_by { |obj| -obj[:star] }
    end

    send_event('github_incubator_repos', { items: repos.slice(0, max_length) })

  end # if

end # SCHEDULER