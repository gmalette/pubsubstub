module Pubsubstub
  class StreamAction < Pubsubstub::Action
    include Logging

    def initialize(*)
      super
      @subscriptions = Set.new
      start_heartbeat
      start_subscriber
    end

    get '/', provides: 'text/event-stream' do
      status(200)
      headers({
        'Cache-Control' => 'no-cache',
        'X-Accel-Buffering' => 'no',
        'Connection' => 'keep-alive',
      })

      subscribe_connection
    end

    private

    def last_event_id
      request.env['HTTP_LAST_EVENT_ID']
    end

    def subscribe_connection
      stream(:keep_open) do |connection|
        subscription = subscribe(params[:channels] || [:default], connection)
        connection.callback do
          unsubscribe(subscription)
        end
        subscription.stream(last_event_id)
      end
    end

    def subscribe(*args)
      new_subscription = Subscription.new(*args)
      @subscriptions << new_subscription
      new_subscription
    end

    def unsubscribe(subscription)
      @subscriptions.delete(subscription)
    end

    def ensure_connection_has_event(connection)
      return if last_event_id
      backlog << heartbeat_event.to_message
    end

    def start_subscriber
      @subscriber = Thread.start do
        # TODO: reconnection and error reporting
        Pubsubstub.subscriber.start
      end
    end

    def start_heartbeat
      @heartbeat = Thread.new do
        # TODO: reconnection and error reporting
        loop do
          sleep Pubsubstub.heartbeat_frequency
          event = Pubsubstub.heartbeat_event
          @subscriptions.each { |subscription| subscription.push(event) }
        end
      end
    end
  end
end
