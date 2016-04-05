RACK_ENV = ENV['RACK_ENV'].freeze

$LOAD_PATH.unshift File.expand_path(File.join(PROJECT_ROOT, 'app'), PROJECT_ROOT)
require 'app'
