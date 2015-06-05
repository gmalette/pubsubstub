module Pubsubstub
  class StreamAction < Pubsubstub::Action
    RECONNECT_TIMEOUT = 10_000

    def initialize(*)
      super
      start_heartbeat
    end

    get '/', provides: 'text/event-stream' do
      status(200)
      headers({
        'Cache-Control' => 'no-cache',
        'X-Accel-Buffering' => 'no',
        'Connection' => 'keep-alive',
      })

      if EventMachine.reactor_running?
        subscribe_connection
      else
        return_scrollback
      end
    end

    private

    def return_scrollback
      buffer = ''
      ensure_connection_has_event(buffer)

      with_each_channel do |channel|
        channel.scrollback(buffer, last_event_id)
      end

      buffer
    end

    def last_event_id
      request.env['HTTP_LAST_EVENT_ID']
    end

    def subscribe_connection
      stream(:keep_open) do |connection|
        @connections << connection
        ensure_connection_has_event(connection)
        with_each_channel do |channel|
          channel.subscribe(connection, last_event_id: last_event_id)
        end

        connection.callback do
          @connections.delete(connection)
          with_each_channel do |channel|
            channel.unsubscribe(connection)
          end
        end
      end
    end

    def ensure_connection_has_event(connection)
      return if last_event_id
      connection << heartbeat_event.to_message
    end

    def start_heartbeat
      return unless EventMachine.reactor_running?
      EventMachine::PeriodicTimer.new(Pubsubstub.heartbeat_frequency) do
        sleep Pubsubstub.heartbeat_frequency
        event = heartbeat_event.to_message
        @connections.each { |connection| connection << event }
      end
    end

    def with_each_channel(&block)
      channels = params[:channels] || [:default]
      channels.each do |channel_name|
        yield channel(channel_name)
      end
    end

    def heartbeat_event
      Event.new('ping', name: 'heartbeat', retry_after: RECONNECT_TIMEOUT)
    end
  end
end
