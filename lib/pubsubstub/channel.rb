module Pubsubstub
  class Channel
    attr_reader :name

    def initialize(name)
      @name = name
      @subscribed = false
    end

    def subscribed?
      @subscribed
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

    def unsubscribe
      redis.publish(pubsub_key, termination_id)
    end

    def subscribe(last_event_id: nil, &block)
      scrollback(since: last_event_id).each(&block) if last_event_id

      pubsub_redis.subscribe(pubsub_key) do |on|
        on.subscribe do |channel, subscriptions|
          @subscribed = true
        end

        on.message do |channel, message|
          if message.start_with?('pubsubstub:unsubscribe:')
            pubsub_redis.unsubscribe if message == termination_id
          else
            yield Event.from_json(message)
          end
        end

        on.unsubscribe do |channel, subscriptions|
          @subscribed = false
        end
      end
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

    private

    # The Redis client suround all calls with a mutex.
    # As such it is crucial to use a dedicated Redis client when blocking on a `subscribe` call.
    def pubsub_redis
      @pubsub_redis ||= Pubsubstub.new_redis
    end

    def termination_id
      @termination_id ||= "pubsubstub:unsubscribe:#{Random.rand(2 ** 64)}"
    end
  end
end
