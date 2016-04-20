module Pubsubstub
  class Subscriber
    include Mutex_m

    def initialize
      super
      @subscribed = false
      @listeners = {}
    end

    def subscribed?
      @subscribed
    end

    def add_event_listener(channel_key, callback)
      synchronize do
        @listeners[channel_key] ||= Set.new
        !!@listeners[channel_key].add?(callback)
      end
    end

    def remove_event_listener(channel_key, callback)
      synchronize do
        return unless @listeners[channel_key]
        !!@listeners[channel_key].delete?(callback)
      end
    end

    def stop
      # redis.client.call allow to bypass the client mutex
      # Since we now that the only other possible caller is blocking on reading the socket this is safe
      synchronize do
        redis.client.call(['punsubscribe', pubsub_pattern])
      end
    end

    def start
      redis.psubscribe(pubsub_pattern) do |on|
        on.psubscribe do
          @subscribed = true
        end

        on.punsubscribe do
          @subscribed = false
        end

        on.pmessage do |pattern, pubsub_key, message|
          process_message(pubsub_key, message)
        end
      end
    end

    def pubsub_pattern
      '*.pubsub'
    end

    def process_message(pubsub_key, message)
      channel_name = Channel.name_from_pubsub_key(pubsub_key)
      event = Event.from_json(message)
      dispatch_event(channel_name, event)
    end

    def dispatch_event(channel_name, event)
      listeners_for(channel_name).each do |listener|
        listener.call(event)
      end
    end

    private

    def listeners_for(channel_name)
      @listeners.fetch(channel_name) { [] }
    end

    # The Redis client suround all calls with a mutex.
    # As such it is crucial to use a dedicated Redis client when blocking on a `subscribe` call.
    def redis
      @redis ||= Pubsubstub.new_redis
    end
  end
end
