RACK_ENV = ENV['RACK_ENV'].freeze

def method_missing(m, *_args, &_block)
  RACK_ENV == m.to_s.chop if m =~ /.*?\?/
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

require 'app'
