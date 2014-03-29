module Pubsubstub
  class RedisPubSub
    def initialize(channel_name)
      @channel_name = channel_name
    end

    def subscribe(callback)
      RedisPubSub.sub.subscribe(key('pubsub'), callback)
    end

    def unsubscribe(callback)
      RedisPubSub.sub.unsubscribe_proc(key('pubsub'), callback)
    end

    def publish(event)
      self.class.publish(@channel_name, event)
    end

    protected
    def key(purpose)
      [@channel_name, purpose].join(".")
    end

    class << self
      def publish(channel_name, event)
        RedisPubSub.pub.publish("#{channel_name}.pubsub", event.to_json)
        RedisPubSub.redis.zadd("#{channel_name}.scrollback", event.id, event.to_json)
      end

      def redis
        @redis ||= redis_connection
      end

      def pub
        @pub ||= redis.pubsub
      end

      def sub
        @sub ||= redis_connection.pubsub
      end

      def redis_connection
        EM::Hiredis.connect(ENV['REDIS_URL'] || "redis://localhost:6379")
      end
    end
  end
end
