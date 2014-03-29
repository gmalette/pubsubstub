require 'spec_helper'

describe Pubsubstub::RedisPubSub do

  context "class singleton methods" do
    subject { Pubsubstub::RedisPubSub }

    describe "#publish" do
      let(:redis) { double('redis') }
      let(:event) { double('Event', to_json: "event_data", id: 1234) }
      before {
        allow(subject).to receive(:blocking_redis) { redis }
      }

      it "publishes the event to a redis channel and adds it to the scrollback" do
        expect(redis).to receive(:publish).with("test.pubsub", event.to_json)
        expect(redis).to receive(:zadd).with("test.scrollback", event.id, event.to_json)
        subject.publish("test", event)
      end
    end

    describe "#sub" do
      it "memoizes the connection" do
        expect(subject.send(:sub)).to be == subject.send(:sub)
      end
    end
  end

  context "pubsub" do
    subject { Pubsubstub::RedisPubSub.new("test") }
    let(:pubsub) { double('redis pubsub') }
    let(:callback) { ->{} }

    describe "#subscribe" do
      before {
        allow(subject.class).to receive(:sub) { pubsub }
      }

      it "creates a redis sub with the callback" do
        expect(pubsub).to receive(:subscribe).with("test.pubsub", callback)
        subject.subscribe(callback)
      end
    end

    describe "#unsubscribe" do
      before {
        allow(subject.class).to receive(:sub) { pubsub }
      }

      it "creates a redis sub with the callback" do
        expect(pubsub).to receive(:unsubscribe_proc).with("test.pubsub", callback)
        subject.unsubscribe(callback)
      end
    end

    describe "#publish" do
      let(:event) { Pubsubstub::Event.new("toto") }
      it "delegates to RedisPubSub.publish" do
        expect(Pubsubstub::RedisPubSub).to receive(:publish).with("test", event)
        subject.publish(event)
      end
    end
  end
end
