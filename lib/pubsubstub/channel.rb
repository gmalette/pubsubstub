module Pubsubstub
  class Channel
    class << self
      def name_from_pubsub_key(key)
        key.sub(/\.pubsub$/, '')
      end
    end

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def publish(event)
      redis.pipelined do
        redis.zadd(scrollback_key, event.id, event.to_json)
        redis.zremrangebyrank(scrollback_key, 0, -Pubsubstub.channels_scrollback_size)
        redis.expire(scrollback_key, Pubsubstub.channels_scrollback_ttl)
        redis.publish(pubsub_key, event.to_json)
      end
    end

    def scrollback(since: )
      redis.zrangebyscore(scrollback_key, Integer(since) + 1, '+inf').map(&Event.method(:from_json))
    end

    def scrollback_key
      "#{name}.scrollback"
    end

    def pubsub_key
      "#{name}.pubsub"
    end

    def redis
      Pubsubstub.redis
    end
  end
end
