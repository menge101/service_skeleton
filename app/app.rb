require 'grape'
require 'grape/middleware/logger'
require 'logstash-logger'
require 'statsd-instrument'
$LOAD_PATH.unshift(File.join(PROJECT_ROOT, 'app', 'initializers'))
require 'system'
require 'logging'
require 'monitoring'
require 'db'

module Skeleton
  # This class defined the API root for this service
  class API < Grape::API
    use Grape::Middleware::Logger, logger: LOGGER
    StatsD.prefix = downcase.gsub(/::/, '__')

    version 'v0', using: :path
    prefix 'api'
    format :json

    get '/ping' do
      StatsD.increment 'ping'
      StatsD.measure('ping') { { data: 'pong' } }
    end
  end
end
