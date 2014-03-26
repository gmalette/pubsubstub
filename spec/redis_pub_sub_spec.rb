require 'spec_helper'

describe Pubsubstub::RedisPubSub do

  it "opens different connections for #pub and #sub" do
    expect(subject.pub).not_to be == (subject.sub)
  end

  describe "#pub" do
    it "memoizes the connection" do
      expect(subject.pub).to be == (subject.pub)
    end
  end

  describe "#sub" do
    it "memoizes the connection" do
      expect(subject.sub).to be == (subject.sub)
    end
  end
end
