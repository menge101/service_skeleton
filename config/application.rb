RACK_ENV = ENV['RACK_ENV'].freeze
puts "Racking up in #{RACK_ENV} mode"

$LOAD_PATH.unshift File.expand_path(File.join(PROJECT_ROOT, 'app'), PROJECT_ROOT)
require 'app'
