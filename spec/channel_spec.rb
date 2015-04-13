require 'spec_helper'

describe Pubsubstub::Channel do
  let(:pubsub) { double(Pubsubstub::RedisPubSub, publish: true, subscribe: true, unsubscribe: true) }
  subject { Pubsubstub::Channel.new("test") }
  before { allow(subject).to receive(:pubsub) { pubsub } }

  context "#initialize" do
    it "does not subscribe immediately" do
      expect(pubsub).not_to receive(:subscribe)
      Pubsubstub::Channel.new('test')
    end
  end

  context "#subscribe" do
    let(:connection) { double('connection') }
    it "subscribes the client" do
      subject.subscribe(connection)
      expect(subject.subscribed?(connection)).to be true
    end

    it "starts subscribing to the channel if it's the first client" do
      expect(pubsub).to receive(:subscribe)
      subject.subscribe(connection)
    end

    it "does not starts subscribing to the channel if it's not the first client" do
      subject.subscribe(connection)
      expect(pubsub).not_to receive(:subscribe)
      subject.subscribe(double('connection'))
    end

    it "sends the scrollback if a last_event_id is passed" do
      event = Pubsubstub::Event.new("event")
      expect(pubsub).to receive(:scrollback).with(1234).and_yield(event)
      expect(connection).to receive(:<<).with(event.to_message)
      subject.subscribe(connection, last_event_id: 1234)
    end
  end

  context "#unsubscribe" do
    let(:connection) { double('connection') }
    before { subject.subscribe(connection) }

    it "unsubscribes the client" do
      expect(subject.subscribed?(connection)).to be true
      subject.unsubscribe(connection)
      expect(subject.subscribed?(connection)).to be false
    end

    it "does not stop listening if it's not the last client" do
      subject.subscribe(double('connection'))
      expect(pubsub).not_to receive(:unsubscribe)
      subject.unsubscribe(connection)
    end

    it "stops listening if it's the last client" do
      expect(pubsub).to receive(:unsubscribe)
      subject.unsubscribe(connection)
    end
  end

  context "#publish" do
    it "forwards to the pubsub" do
      event = double('event')
      expect(pubsub).to receive(:publish).with(event)
      subject.publish(event)
    end
  end

  context "broadcasting events from redis" do
    let(:event) { Pubsubstub::Event.new("message", name: "toto") }
    let(:connection) { double('connection') }
    before {
      subject.subscribe(connection)
    }

    it "sends the events to the clients" do
      expect(connection).to receive(:<<).with(event.to_message)
      subject.send(:broadcast, event.to_json)
    end
  end
end
