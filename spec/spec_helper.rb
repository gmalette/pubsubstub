require 'rack/test'
require 'pry'
require 'pry-byebug'
require 'timecop'
require 'thread'

require_relative 'support/threading_matchers'

Thread.abort_on_exception = true # ensure no exception stays hidden in threads

ENV['RACK_ENV'] = 'test'
require_relative '../lib/pubsubstub'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.color = true

  config.order = 'random'

  config.before(:each) { Redis.new(url: Pubsubstub.redis_url).flushdb }
end
