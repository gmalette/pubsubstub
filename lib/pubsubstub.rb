require "logger"
require "json"
require "sinatra"
require "em-hiredis"
require "redis"
require "pubsubstub/version"
require "pubsubstub/redis_pub_sub"
require "pubsubstub/channel"
require "pubsubstub/event"
require "pubsubstub/action"
require "pubsubstub/stream_action"
require "pubsubstub/publish_action"
require "pubsubstub/application"

module Pubsubstub
  class << self
    attr_accessor :heartbeat_frequency, :logger, :redis_url
  end
  self.heartbeat_frequency = 15
  self.logger = Logger.new(STDOUT).tap do |logger|
    logger.progname = "Pubsubstub"
  end
end

