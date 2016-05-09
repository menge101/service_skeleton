logger_hash = if production?
                %w(LOGSTASH_URL LOGSTASH_PORT).each do |var|
                  raise "#{var} must be specified in the environment" unless ENV.key?(var)
                end
                { type: :udp, host: ENV['LOGSTASH_URL'], port: ENV['LOGSTASH_PORT'] }
              else
                { type: :file, path: "log/#{RACK_ENV}.log", sync: true }
              end

LOGGER = LogStashLogger.new(logger_hash)
