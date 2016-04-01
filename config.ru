PROJECT_ROOT = File.expand_path(File.join(__FILE__, '..'))
$LOAD_PATH.unshift(File.expand_path(File.join('.', 'config'), PROJECT_ROOT))
require 'environment'
run Skeleton::API
