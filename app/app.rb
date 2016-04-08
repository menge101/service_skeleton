require 'grape'
require 'grape-entity'
require 'grape/middleware/logger'
require 'logstash-logger'
require 'statsd-instrument'
$LOAD_PATH.unshift(File.expand_path(File.join('app', 'initializers')))
require 'system'
require 'logging'
require 'monitoring'
require 'db'
$LOAD_PATH.unshift(File.expand_path(File.join('app', 'api')))
require 'bone'

module Skeleton
  # This class defined the API root for this service
  class API < Grape::API
    use Grape::Middleware::Logger, logger: LOGGER
    StatsD.prefix = downcase.gsub(/::/, '__')

    version 'v0', using: :path
    prefix 'api'
    format :json

    mount ::Skeleton::Bones

    get '/ping' do
      StatsD.increment 'ping'
      StatsD.measure('ping') { { data: 'pong' } }
    end
  end
end
