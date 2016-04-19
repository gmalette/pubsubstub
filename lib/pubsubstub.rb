require "json"
require "sinatra"
require "redis"
require "pubsubstub/version"
require "pubsubstub/channel"
require "pubsubstub/event"
require "pubsubstub/action"
require "pubsubstub/stream_action"
require "pubsubstub/publish_action"
require "pubsubstub/application"

module Pubsubstub
  class << self
    attr_accessor :heartbeat_frequency, :redis_url, :channels_scrollback_size, :channels_scrollback_ttl
  end

  self.heartbeat_frequency = 15
  self.redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  self.channels_scrollback_size = 1000
  self.channels_scrollback_ttl = 24 * 60 * 60
end
