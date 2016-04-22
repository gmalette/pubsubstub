module Pubsubstub
  class Subscription
    include Logging

    attr_reader :channels, :connection, :queue, :id

    def initialize(channels, connection)
      @id = Random.rand(2 ** 64)
      @connection = connection
      @channels = channels
      @queue = Queue.new
    end

    def stream(last_event_id)
      info { "Connecting client ##{id} (#{channels.map(&:name).join(', ')})" }
      fetch_scrollback(last_event_id)
      subscribe
      while event = queue.pop
        debug { "Sending event ##{event.id} to client ##{id}"}
        connection << event.to_message
      end
    ensure
      info { "Disconnecting client ##{id}" }
      unsubscribe
    end

    def push(event)
      queue.push(event)
    end

    private

    def subscribe
      channels.each { |c| Pubsubstub.subscriber.add_event_listener(c.name, callback) }
    end

    def unsubscribe
      channels.each { |c| Pubsubstub.subscriber.remove_event_listener(c.name, callback) }
    end

    # This method is not ideal as it doesn't guarantee order in case of multi-channel subscription
    def fetch_scrollback(last_event_id)
      event_sent = false
      if last_event_id
        channels.each do |channel|
          channel.scrollback(since: last_event_id).each do |event|
            event_sent = true
            queue.push(event)
          end
        end
      end

      queue.push(Pubsubstub.heartbeat_event) unless event_sent
    end

    # We use store the callback so that the object_id stays the same.
    # Otherwise we wouldn't be able to unsubscribe
    def callback
      @callback ||= method(:push)
    end
  end
end