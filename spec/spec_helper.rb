require 'open3'
require 'rack/test'
require 'pry'
require 'pry-byebug'
require 'timecop'
require 'thread'

require_relative 'support/threading_matchers'
require_relative 'support/http_helpers'

Thread.abort_on_exception = true # ensure no exception stays hidden in threads

ENV['RACK_ENV'] = 'test'
require_relative '../lib/pubsubstub'

Pubsubstub.logger = Logger.new(nil)
Pubsubstub.logger.level = Logger::DEBUG

# Fake EM
module EventMachine
  extend self

  def reactor_running?
    false
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include HTTPHelpers

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.color = true

  config.order = 'random'

  config.before(:each) { Redis.new(url: Pubsubstub.redis_url).flushdb }

  # Clean threads after finish
  config.after(:each) do
    Thread.list.each { |thread| thread.join(0.5) if thread != Thread.current }
  end
end
