require 'spec_helper'

describe Pubsubstub::RedisPubSub do

  context "class singleton methods" do
    subject { Pubsubstub::RedisPubSub }
    it "opens different connections for #pub and #sub" do
      expect(subject.send(:pub)).not_to be == subject.send(:sub)
    end

    describe "#pub" do
      it "memoizes the connection" do
        expect(subject.send(:pub)).to be == subject.send(:pub)
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

    describe "#publish" do
      let(:redis) { double('redis') }
      let(:event) { double('Event', to_json: "event_data", id: 1234) }
      before {
        allow(subject.class).to receive(:pub) { pubsub }
        allow(subject.class).to receive(:redis) { redis }
      }

      it "publishes the event to a redis channel and adds it to the scrollback" do
        expect(pubsub).to receive(:publish).with("test.pubsub", event.to_json)
        expect(redis).to receive(:zadd).with("test.scrollback", event.id, event.to_json)
        subject.publish(event)
      end
    end
  end
end
