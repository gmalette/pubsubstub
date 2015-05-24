module Pubsubstub
  class Channel
    attr_reader :name, :pubsub

    def initialize(name)
      @name = name
      @pubsub = RedisPubSub.new(name)
      @connections = []
    end

    def subscribe(connection, options = {})
      listen if @connections.empty?
      @connections << connection
      scrollback(connection, options[:last_event_id])
    end

    def subscribed?(connection)
      @connections.include?(connection)
    end

    def unsubscribe(connection)
      @connections.delete(connection)
      stop_listening if @connections.empty?
    end

    def publish(event)
      pubsub.publish(event)
    end

    def scrollback(connection, last_event_id)
      return unless last_event_id
      pubsub.scrollback(last_event_id) do |event|
        connection << event.to_message
      end
    end

    private

    def broadcast(json)
      string = Event.from_json(json).to_message
      @connections.each do |connection|
        connection << string
      end
    end

    def listen
      pubsub.subscribe(method(:broadcast))
    end

    def stop_listening
      pubsub.unsubscribe(method(:broadcast))
    end
  end
end
