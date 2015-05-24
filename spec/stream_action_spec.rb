require 'spec_helper'

describe "Pubsubstub::StreamAction without EventMachine" do
  before {
    allow(EventMachine).to receive(:reactor_running?).and_return(false)
  }

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
    expect_any_instance_of(Pubsubstub::Channel).to receive(:scrollback).and_return([event])

    get "/", {}, 'HTTP_LAST_EVENT_ID' => 1
  end
end

describe "Pubsubstub::StreamAction with EventMachine" do
  include EventMachine::SpecHelper

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

  it "subscribes the connection to the channel" do
    event = Pubsubstub::Event.new('ping')
    channel = Pubsubstub::Channel.new(:default)
    allow_any_instance_of(Pubsubstub::StreamAction).to receive(:with_each_channel).and_yield(channel)

    em do
      env = current_session.send(:env_for, "/", 'HTTP_LAST_EVENT_ID' => 1)
      request = Rack::Request.new(env)
      status, headers, body = app.call(request.env)

      response = Rack::MockResponse.new(status, headers, body, env["rack.errors"].flush)
      channel.send(:broadcast, event.to_json)

      EM.next_tick {
        body.close
        response.finish

        expect(response.body).to eq(event.to_message)
        EM.stop
      }
    end
  end
end
