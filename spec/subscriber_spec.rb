require 'spec_helper'

RSpec.describe Pubsubstub::Subscriber do
  describe "#start" do
    let(:channel) { Pubsubstub::Channel.new('plop') }
    let(:events) { (1..10).map { |i| Pubsubstub::Event.new("refresh ##{i}", id: i) } }

    it "blocks and yield every published events" do
      published_events = []
      subject.add_event_listener('plop', -> (event) { published_events << event })
      subscribe_thread = Thread.new { subject.start }

      expect { subject.subscribed? }.to happen.in_under(1)

      events.each(&channel.method(:publish))

      expect { published_events.size == events.size }.to happen.in_under(2)

      subject.stop

      subscribe_thread.join(2)

      expect { ! subject.subscribed? }.to happen.in_under(1)

      expect(subscribe_thread).to complete

      expect(published_events).to be == events
    end
  end

  describe "#dispatch_event" do
    let(:event) { Pubsubstub::Event.new('Hello', id: 1) }

    it "calls all listeners of the channel" do
      events_a = []
      events_b = []
      events_c = []

      subject.add_event_listener('plop', ->(event) { events_a << event })
      subject.add_event_listener('plop', ->(event) { events_b << event })
      subject.add_event_listener('foo', ->(event) { events_c << event })

      subject.send(:dispatch_event, 'plop', event)

      expect(events_a).to be == [event]
      expect(events_b).to be == [event]
      expect(events_c).to be_empty
    end
  end
end
