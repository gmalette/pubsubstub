require 'spec_helper'

RSpec.describe Pubsubstub::Event do
  subject {
    Pubsubstub::Event.new("refresh #1500\nnew #1400", id: 12345678, name: "toto", retry_after: 1_000)
  }

  it "#to_json serialization" do
    expect(subject.to_json).to be == {id: 12345678, name: "toto", data: "refresh #1500\nnew #1400", retry_after: 1_000}.to_json
  end

  context "#to_message" do
    it "serializes to sse" do
      expect(subject.to_message).to be == "id: 12345678\nevent: toto\nretry: 1000\ndata: refresh #1500\ndata: new #1400\n\n"
    end

    it "does not have event if no name is specified" do
      event = Pubsubstub::Event.new("refresh", id: 1234)
      expect(event.to_message).to be == "id: 1234\ndata: refresh\n\n"
    end
  end

  it ".from_json" do
    json = subject.to_json
    expect(Pubsubstub::Event.from_json(json).to_json).to be == json
  end

  it "== another event if they are the same" do
    expect(subject).to be == Pubsubstub::Event.from_json(subject.to_json)
  end
end
