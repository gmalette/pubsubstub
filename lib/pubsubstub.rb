require "logger"
require "mutex_m"
require "json"
require "set"

require "sinatra"
require "redis"
require "pubsubstub/version"
require "pubsubstub/logging"
require "pubsubstub/channel"
require "pubsubstub/subscriber"
require "pubsubstub/subscription"
require "pubsubstub/event"
require "pubsubstub/action"
require "pubsubstub/stream_action"
require "pubsubstub/publish_action"
require "pubsubstub/application"

module Pubsubstub
  extend Mutex_m

  class << self
    attr_accessor :heartbeat_frequency, :redis_url, :channels_scrollback_size,
      :channels_scrollback_ttl, :logger, :reconnect_timeout, :error_handler

    def publish(channel_name, *args)
      Channel.new(channel_name).publish(Event.new(*args))
      nil
    end

    def redis_url=(url)
      @redis_url = url.to_s
      @redis = nil
    end

    def redis
      @redis || synchronize { @redis ||= new_redis }
    end

    def new_redis
      Redis.new(url: redis_url)
    end

    def subscriber
      @subscriber || synchronize { @subscriber ||= Subscriber.new }
    end

    def heartbeat_event
      Event.new('ping', name: 'heartbeat', retry_after: reconnect_timeout)
    end

    def handle_error(error)
      logger.error("Uncaught exception: #{error.class}: #{error.message}\n#{error.backtrace.join("\n\t")}\n")
      error_handler && error_handler.call(error)
    end

    def report_errors
      yield
    rescue => error
      handle_error(error)
      raise
    end
  end

  self.logger = Logger.new(STDOUT)
  self.logger.level = Logger::DEBUG
  self.heartbeat_frequency = 15
  self.redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  self.channels_scrollback_size = 1000
  self.channels_scrollback_ttl = 24 * 60 * 60
  self.reconnect_timeout = 10_000

  # Deprecated. Use Pubsubstub.publish instead
  module RedisPubSub
    extend self

    def publish(channel_name, event)
      Channel.new(channel_name).publish(event)
    end
  end
end
