if production?
  %w(STATSD_URL STATSD_PORT).each do |var|
    raise "#{var} must be specified in the environment" unless ENV.key? var
  end
  StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new((ENV['STATSD_URL'] + ':' + ENV['STATSD_PORT']), :statsd)
else
  stats_logger = LogStashLogger.new(type: :file, path: "log/#{RACK_ENV}_stats.log", sync: true)
  StatsD.backend = StatsD::Instrument::Backends::LoggerBackend.new(stats_logger)
end
