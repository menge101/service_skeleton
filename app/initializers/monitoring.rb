if production?
  StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new((STATSD_URL + ':' + STATSD_PORT), :statsd)
else
  stats_logger = LogStashLogger.new(type: :file, path: "log/#{RACK_ENV}_stats.log", sync: true)
  StatsD.backend = StatsD::Instrument::Backends::LoggerBackend.new(stats_logger)
end
