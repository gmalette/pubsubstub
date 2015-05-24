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

  describe "#scrollback" do
    subject { Pubsubstub::RedisPubSub.new("test") }

    let(:event1) { Pubsubstub::Event.new("toto", id: 1235) }
    let(:event2) { Pubsubstub::Event.new("toto", id: 1236) }

    it "yields the events in the scrollback" do
      redis = double('redis')
      expect(redis).to receive(:zrangebyscore).with('test.scrollback', '(1234', '+inf').and_yield([event1.to_json, event2.to_json])
      expect(Pubsubstub::RedisPubSub).to receive(:blocking_redis).and_return(redis)
      expect { |block| subject.scrollback(1234, &block) }.to yield_successive_args(event1, event2)
    end
  end
end
