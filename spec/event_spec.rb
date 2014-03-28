require 'spec_helper'

describe Pubsubstub::Event do
  subject { Pubsubstub::Event.new(12345678, "toto", "refresh #1500\nnew #1400") }

  it "#to_json serialization" do
    expect(subject.to_json).to be == {id: 12345678, name: "toto", data: "refresh #1500\nnew #1400"}.to_json
  end

  it "#to_message" do
    expect(subject.to_message).to be == "id: 12345678\nevent: toto\ndata: refresh #1500\ndata: new #1400\n\n"
  end
end
