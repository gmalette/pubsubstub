require 'spec_helper'

describe "Pubsubstub::StreamAction without EventMachine" do
  let(:app) { Pubsubstub::StreamAction.new }
  it "returns a heartbeat if there is no LAST_EVENT_ID" do
    Timecop.freeze(DateTime.parse("2015-01-01T00:00:00+00:00")) do
      event = Pubsubstub::Event.new(
        'ping',
        name: 'heartbeat',
        retry_after: Pubsubstub::StreamAction::RECONNECT_TIMEOUT,
      )
      get "/"
      expect(last_response.body).to eq(event.to_message)
    end
  end

  it "returns an empty body if a LAST_EVENT_ID is provided and there is no scrollback" do
    get "/", {}, 'HTTP_LAST_EVENT_ID' => 1
    expect(last_response.body).to eq('')
  end

  it "returns the content of the scrollback" do
    event = Pubsubstub::Event.new("test")
    Pubsubstub::RedisPubSub.publish(:default, event)

    get "/", {}, 'HTTP_LAST_EVENT_ID' => 1
    expect(last_response.body).to eq(event.to_message)
  end
end

describe "Pubsubstub::StreamAction with EventMachine" do
  pending("We're getting rid of event machine")
  let(:app) {
    Pubsubstub::StreamAction.new
  }

  it "returns a heartbeat if there is no LAST_EVENT_ID" do
    Timecop.freeze(DateTime.parse("2015-01-01T00:00:00+00:00")) do
      event = Pubsubstub::Event.new(
        'ping',
        name: 'heartbeat',
        retry_after: Pubsubstub::StreamAction::RECONNECT_TIMEOUT,
      )
      get "/"
      expect(last_response.body).to eq(event.to_message)
    end
  end

  it "returns the content of the scrollback right away" do
    event = Pubsubstub::Event.new("test")
    Pubsubstub::RedisPubSub.publish(:default, event)
    expect_any_instance_of(EventMachine::Hiredis::Client).to receive(:zrangebyscore).and_yield([event.to_json])

    em do
      env = current_session.send(:env_for, "/", 'HTTP_LAST_EVENT_ID' => 1)
      request = Rack::Request.new(env)
      status, headers, body = app.call(request.env)

      response = Rack::MockResponse.new(status, headers, body, env["rack.errors"].flush)

      EM.next_tick {
        body.close
        response.finish

        expect(response.body).to eq(event.to_message)
        EM.stop
      }
    end
  end

  it "subscribes the connection to the channel" do
    em do
      redis = spy('Redis Pubsub')
      allow(Pubsubstub::RedisPubSub).to receive(:sub).and_return(redis)
      expect(redis).to receive(:subscribe).with("default.pubsub", anything)

      env = current_session.send(:env_for, "/", 'HTTP_LAST_EVENT_ID' => 1)
      request = Rack::Request.new(env)
      status, headers, body = app.call(request.env)

      response = Rack::MockResponse.new(status, headers, body, env["rack.errors"].flush)

      EM.next_tick {
        body.close
        response.finish
        EM.stop
      }
    end
  end

  it "sends heartbeat events every now and then" do
    allow(Pubsubstub).to receive(:heartbeat_frequency).and_return(0.001)

    Timecop.freeze do
      em do
        env = current_session.send(:env_for, "/", 'HTTP_LAST_EVENT_ID' => 1)
        request = Rack::Request.new(env)
        status, headers, body = app.call(request.env)

        response = Rack::MockResponse.new(status, headers, body, env["rack.errors"].flush)

        event = Pubsubstub::Event.new('ping', name: 'heartbeat', retry_after: Pubsubstub::StreamAction::RECONNECT_TIMEOUT)

        EM.add_timer(0.002) {
          body.close
          response.finish

          expect(response.body).to start_with(event.to_message)
          EM.stop
        }
      end
    end
  end
end
