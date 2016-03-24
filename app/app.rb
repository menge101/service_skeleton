require 'grape'
require 'grape/middleware/logger'
require 'logstash-logger'
require 'statsd-instrument'

module Skeleton
  class API < Grape::API
    def self.const_missing(name)
      if ENV.has_key?(name.to_s)
        ENV[name.to_s]
      else
        raise "Undefined constant: #{name}"
      end
    end

    use Grape::Middleware::Logger, { logger: LogStashLogger.new(type: :udp, host: "#{LOGSTASH_URL}", port: "#{LOGSTASH_PORT}") }

    StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new("#{STATSD_URL}:#{STATSD_PORT}", :statsd)
    StatsD.prefix = self.to_s.downcase.gsub(/::/, '_')
    version 'v0', using: :path
    prefix 'api'
    format :json

    get '/ping' do
      StatsD.increment 'ping'
      StatsD.measure('ping') { { data: 'pong' } }
    end
  end
end