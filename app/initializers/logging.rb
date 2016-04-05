logger_hash = if production?
                { type: :udp, host: LOGSTASH_URL, port: LOGSTASH_PORT }
              else
                { type: :file, path: "log/#{RACK_ENV}.log", sync: true }
              end

LOGGER = LogStashLogger.new(logger_hash)
