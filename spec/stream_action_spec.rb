require 'spec_helper'

RSpec.shared_examples "short lived connections" do
  it "immediately returns the scrollback" do
    Pubsubstub.publish('foo', 'bar', id: 1)
    Pubsubstub.publish('foo', 'baz', id: 2)

    get '/?channels[]=foo', {}, 'HTTP_LAST_EVENT_ID' => 1
    expect(last_response.body).to eq("id: 2\ndata: baz\n\n")
  end

  it "returns and heartbeat if scrollback is empty" do
    Timecop.freeze('2015-01-01T00:00:00+00:00') do
      get '/'
      message = "id: 1420070400000\nevent: heartbeat\nretry: #{Pubsubstub.reconnect_timeout}\ndata: ping\n\n"
      expect(last_response.body).to eq(message)
    end
  end
end

describe Pubsubstub::StreamAction do
  let(:app) { Pubsubstub::StreamAction.new }

  context "with EventMachine" do
    before do
      allow(EventMachine).to receive(:reactor_running?).and_return(true)
    end

    it_behaves_like "short lived connections"
  end

  context "with persistent connections disabled" do
    around :example do |example|
      previous = Pubsubstub.use_persistent_connections
      Pubsubstub.use_persistent_connections = false
      example.run
      Pubsubstub.use_persistent_connections = previous
    end

    it_behaves_like "short lived connections"
  end

  it "immediately send a heartbeat event if there is no scrollback" do
    with_background_server do
      expect(9292).to listen.in_under(5)

      chunks = async_get('http://localhost:9292/?channels[]=foo', 'Last-Event-Id' => '0')
      expect(chunks.pop).to include("event: heartbeat\n")

      Pubsubstub.publish('foo', 'bar', id: 1)
      expect(chunks.pop).to include("id: 1\n")

      Pubsubstub.publish('foo', 'baz', id: 2)
      expect(chunks.pop).to include("id: 2\n")
    end
  end

  it "sends the scrollback if there is some" do
    Pubsubstub.publish('foo', 'bar', id: 1)

    with_background_server do
      expect(9292).to listen.in_under(5)

      chunks = async_get('http://localhost:9292/?channels[]=foo', 'Last-Event-Id' => '0')
      expect(chunks.pop).to include("id: 1\n")

      Pubsubstub.publish('foo', 'baz', id: 2)
      expect(chunks.pop).to include("id: 2\n")
    end
  end
end