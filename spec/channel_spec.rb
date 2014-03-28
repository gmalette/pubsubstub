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
      expect(subject.subscribed?(connection)).to be_true
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
  end

  context "#unsubscribe" do
    let(:connection) { double('connection') }
    before { subject.subscribe(connection) }

    it "unsubscribes the client" do
      expect(subject.subscribed?(connection)).to be_true
      subject.unsubscribe(connection)
      expect(subject.subscribed?(connection)).to be_false
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
  end

  context "broadcasting" do
  end
end
