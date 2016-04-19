require 'spec_helper'

describe Pubsubstub::Channel do
  subject { described_class.new('foobar') }

  it "has a name" do
    expect(subject.name).to be == 'foobar'
  end

  describe "#publish" do
    let(:event) { Pubsubstub::Event.new("refresh #1", id: 1) }

    it "records the event in the scrollback" do
      expect {
        subject.publish(event)
      }.to change { subject.scrollback(since: 0) }.from([]).to([event])
    end
  end

  describe "#scrollback" do
    before do
      10.times do |i|
        subject.publish(Pubsubstub::Event.new("refresh ##{i}", id: i))
      end
    end

    it "returns the events with an id greater than the `since` parameter" do
      expect(subject.scrollback(since: 5).map(&:id)).to be == [6, 7, 8, 9]
    end
  end
end
