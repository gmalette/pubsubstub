p File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'pubsubstub'

run Pubsubstub::Application
