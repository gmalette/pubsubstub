module Pubsubstub
  class Channel
    attr_reader :name, :pubsub

    def initialize(name)
      @name = name
      @pubsub = RedisPubSub.new(name)
      @connections = []
    end

    def subscribe(connection)
      # logger.debug "[Channel] Subscribing #{id} to #{@name}"
      listen if @connections.empty?
      @connections << connection
    end

    def subscribed?(connection)
      @connections.include?(connection)
    end

    def unsubscribe(connection)
      @connections.delete(connection)
      stop_listening if @connections.empty?
    end

    def publish(event)
      # logger.debug "[Channel] Publishing to #{@name}"
      pubsub.publish(event)
    end

    private
    def broadcast(event)
      string = event.to_message
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
