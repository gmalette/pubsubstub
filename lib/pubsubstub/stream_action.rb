module Pubsubstub
  class StreamAction < Pubsubstub::Action
    include Logging

    def initialize(*)
      super
      @subscriptions = Set.new
      @mutex = Mutex.new
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
      start_heartbeat
      start_subscriber

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
      return if defined?(@subscriber)
      @mutex.synchronize do
        return if defined?(@subscriber)
        @subscriber = Thread.start do
          Pubsubstub.logger.info "Starting subscriber"
          Pubsubstub.report_errors do
            begin
              Pubsubstub.subscriber.start
            rescue Redis::BaseConnectionError => error
              Pubsubstub.logger.error "Can't subscribe to Redis (#{error.class}: #{error.message}). Retrying in 1 second"
              sleep 1
              retry
            end
          end
        end
      end
    end

    def start_heartbeat
      return if defined?(@heartbeat)
      @mutex.synchronize do
        return if defined?(@heartbeat)
        @heartbeat = Thread.new do
          Pubsubstub.logger.info "Starting heartbeat"
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
end
