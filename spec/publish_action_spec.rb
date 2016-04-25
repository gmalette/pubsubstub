require 'spec_helper'

describe Pubsubstub::StreamAction do
  let(:app) { Pubsubstub::PublishAction.new }
  let(:channel) { Pubsubstub::Channel.new('foo') }

  it "adds the event to the scrollback" do
    expect {
      post '/?channels[]=foo', {'event' => 'hello', 'data' => 'world!'}
      expect(last_response.status).to eq 200
    }.to change { channel.scrollback(since: 0).size }.from(0).to(1)
  end
end
