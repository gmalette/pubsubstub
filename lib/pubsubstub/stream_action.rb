module Pubsubstub
  class StreamAction < Pubsubstub::Action
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
      stream(:keep_open) do |connection|
        @connections << connection
        channels = params[:channels] || [:default]
        channels.each do |channel_name|
          channel(channel_name).subscribe(connection, last_event_id: request.env['HTTP_LAST_EVENT_ID'])
        end

        connection.callback do
          @connections.delete(connection)
          channels.each do |channel_name|
            channel(channel_name).unsubscribe(connection)
          end
        end
      end
    end

    private
    def start_heartbeat
      @heartbeat = Thread.new do
        loop do
          sleep Pubsubstub.heartbeat_frequency
          event = Event.new('ping', name: 'heartbeat').to_message
          @connections.each { |connection| connection << event }
        end
      end
    end
  end
end
