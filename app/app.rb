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

# This module holds all code relating to the Service
module Skeleton
  # This class defined the API root for this service
  class API < Grape::API
    use Grape::Middleware::Logger, logger: LOGGER
    local_name = name

    prefix 'api'
    mount ::Skeleton::Bones

    version 'v0', using: :path
    format :json

    get '/ping' do
      StatsD.increment Skeleton.stats_string(local_name, 'ping')
      StatsD.measure(Skeleton.stats_string(local_name, 'ping')) { { data: 'pong' } }
    end
  end

  def self.stats_string(name, action)
    name.gsub('::', '.') + '.' + action
  end
end
