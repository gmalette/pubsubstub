require 'pry'
require "sinatra"
require "em-hiredis"
require "pubsubstub/version"
require "pubsubstub/redis_pub_sub"
require "pubsubstub/channel"

module Pubsubstub

  class Application < Sinatra::Base
    def initialize
      @pubsub = RedisPubSub.new
      @channels = Hash.new { |k, h| h[k] = Channel.new(k, @pubsub) }
      super
    end

    def channel(name)
      @channel[name]
    end

    get '/' do
      stream(:keep_open) do |connection|
        (params[:channels] || [:default]).each do |channel_name|
          channel(channel_name).subscribe(connection)
        end
      end
    end

    post '/' do

    end
  end
end
