require "sinatra/cyclist"
require 'dashing'


configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  # See http://www.sinatrarb.com/intro.html > Available Template Languages on
  # how to add additional template languages.
  set :template_languages, %i[html erb]

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

set :routes_to_cycle_through, [:ken, :dod, :social, :code, :bucki]

run Sinatra::Application
