module Pubsubstub
  class Application < Sinatra::Base
    configure :production, :development do
      enable :logging
    end

    def initialize
      @channels = Hash.new { |h, k| h[k] = Channel.new(k) }
      @connections = []
      super
      setup_heartbeat
    end

    def setup_heartbeat
      EM.add_periodic_timer(30) do
        heartbeat = Event.new(time_now, 'heartbeat', '').to_message
        @connections.each { |connection| connection << heartbeat }
      end
    end

    def channel(name)
      @channels[name]
    end

    def time_now
      (Time.now.to_f * 1000).to_i
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
          channel(channel_name).subscribe(connection, last_event_id: request['HTTP_LAST_EVENT_ID'])
        end

        connection.callback do
          @connections.delete(connection)
          channels.each do |channel_name|
            channel(channel_name).unsubscribe(connection)
          end
        end
      end
    end

    post '/' do
      event = Event.new(params[:data], name: params[:event])
      (params[:channels] || [:default]).each do |channel_name|
        channel(channel_name).publish(event)
      end
      ""
    end
  end
end
