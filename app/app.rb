require 'grape'
require 'grape/middleware/logger'
require 'logstash-logger'
require 'statsd-instrument'
$LOAD_PATH.unshift(File.join(PROJECT_ROOT, 'app', 'initializers'))
require 'db'

module Skeleton
  # This class defined the API root for this service
  class API < Grape::API
    def self.const_missing(name)
      raise "Undefined constant: #{name}" unless ENV.key?(name.to_s)
      ENV[name.to_s]
    end

    if production?
      logger = LogStashLogger.new(type: :udp, host: LOGSTASH_URL, port: LOGSTASH_PORT)
      StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new((STATSD_URL + ':' + STATSD_PORT), :statsd)
    else
      logger = LogStashLogger.new(type: :file, path: "log/#{RACK_ENV}.log", sync: true)
      stats_logger = LogStashLogger.new(type: :file, path: "log/#{RACK_ENV}_stats.log", sync: true)
      StatsD.backend = StatsD::Instrument::Backends::LoggerBackend.new(stats_logger)
    end

    use Grape::Middleware::Logger, logger: logger

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
