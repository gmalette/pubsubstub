module Pubsubstub
  class StreamAction
    HEADERS = {
      'Content-Type' => 'text/event-stream',
      'Cache-Control' => 'no-cache',
      'X-Accel-Buffering' => 'no',
      'Connection' => 'keep-alive',
    }.freeze
    include Logging

    def initialize(*)
      @subscriptions = Set.new
      @mutex = Mutex.new
    end

    def call(env)
      spawn_helper_threads
      last_event_id = env['HTTP_LAST_EVENT_ID']
      request = Rack::Request.new(env)
      channels = (request.params['channels'] || [:default]).map(&Channel.method(:new))

      stream = if use_persistent_connections?
        subscribe_connection(channels, last_event_id)
      else
        send_scrollback(channels, last_event_id)
      end
      [200, HEADERS, stream]
    end

    private

    def send_scrollback(channels, last_event_id)
      scrollback_events = []
      scrollback_events = channels.flat_map { |c| c.scrollback(since: last_event_id) } if last_event_id
      scrollback_events = [Pubsubstub.heartbeat_event] if scrollback_events.empty?
      Stream.new do |connection|
        scrollback_events.each do |event|
          connection << event.to_message
        end
      end
    end

    def use_persistent_connections?
      Pubsubstub.use_persistent_connections && !event_machine?
    end

    def event_machine?
      defined?(EventMachine) && EventMachine.reactor_running?
    end

    def subscribe_connection(channels, last_event_id)
      Stream.new do |connection|
        subscription = register(channels, connection)
        begin
          subscription.stream(last_event_id)
        ensure
          release(subscription)
        end
      end
    end

    def register(*args)
      new_subscription = Subscription.new(*args)
      @mutex.synchronize { @subscriptions << new_subscription }
      new_subscription
    end

    def release(subscription)
      @mutex.synchronize { @subscriptions.delete(subscription) }
    end

    def spawn_helper_threads
      return if defined? @helper_threads_initialized
      @mutex.synchronize do
        return if defined? @helper_threads_initialized
        @helper_threads_initialized = true
        if event_machine?
          error { "EventMachine is loaded, running in degraded mode :/"}
        else
          start_subscriber
          start_heartbeat
        end
      end
    end

    def start_subscriber
      Thread.start do
        info { "Starting subscriber" }
        Pubsubstub.report_errors do
          begin
            Pubsubstub.subscriber.start
          rescue Redis::BaseConnectionError => error
            error { "Can't subscribe to Redis (#{error.class}: #{error.message}). Retrying in 1 second" }
            sleep 1
            retry
          end
        end
      end
    end

    def start_heartbeat
      Thread.start do
        info { "Starting heartbeat" }
        Pubsubstub.report_errors do
          loop do
            sleep Pubsubstub.heartbeat_frequency
            event = Pubsubstub.heartbeat_event
            @subscriptions.each { |subscription| subscription.push(event) }
          end
        end
      end
    end
  end
end
