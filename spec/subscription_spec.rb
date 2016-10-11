require 'spec_helper'

RSpec.describe Pubsubstub::Subscription do
  let(:event) { Pubsubstub::Event.new('hello') }
  let(:connection) { [] }
  let(:channels) { %w(foo bar).map(&Pubsubstub::Channel.method(:new)) }
  let(:channel) { Pubsubstub::Channel.new('foo') }
  subject { described_class.new(channels, connection) }

  it "has an id" do
    expect(subject.id).to be_an Integer
  end

  describe "#push" do
    it "stores the event in the queue" do
      expect {
        subject.push(event)
      }.to change { subject.queue.size }
    end
  end

  describe "#stream" do
    context "when there is no scrollback" do
      it "sends an heartbeat event immediately" do
        channel.publish(event)
        subscription_thread = Thread.start { subject.stream(event.id) }

        begin
          expect { connection.size == 1 }.to happen
          expect(connection.first).to include('event: heartbeat')
        ensure
          subscription_thread.kill
        end
      end
    end

    context "when there is a scrollback" do
      it "sends it immediately" do
        channel.publish(event)
        subscription_thread = Thread.start { subject.stream(event.id - 1) }

        begin
          expect { connection.size == 1 }.to happen
          expect(connection.first).to be == event.to_message
        ensure
          subscription_thread.kill
        end
      end
    end

    context "when an event is published" do
      it "forward it to the subscribers" do
        subscriber_thread = Thread.start { Pubsubstub.subscriber.start }
        subscription_thread = Thread.start { subject.stream(event.id - 1) }

        begin
          expect { connection.size == 1 }.to happen
          expect(connection.first).to include('event: heartbeat')

          channel.publish(event)
          expect { connection.size == 2 }.to happen
          expect(connection.last).to be == event.to_message
        ensure
          subscription_thread.kill
          subscriber_thread.kill
        end
      end
    end
  end
end
