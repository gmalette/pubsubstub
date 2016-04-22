require 'spec_helper'


describe Pubsubstub::StreamAction do
  let(:app) { Pubsubstub::StreamAction.new }

  context "with EventMachine" do
    before do
      allow(EventMachine).to receive(:reactor_running?).and_return(true)
    end

    it "immediately returns the scrollback" do
      Pubsubstub.publish('foo', 'bar', id: 1)
      Pubsubstub.publish('foo', 'baz', id: 2)

      get '/?channels[]=foo', {}, 'HTTP_LAST_EVENT_ID' => 1
      expect(last_response.body).to eq("id: 2\ndata: baz\n\n")
    end

    it "returns and heartbeat if scrollback is empty" do
      Timecop.freeze('2015-01-01T00:00:00+00:00') do
        get '/'
        message = "id: 1420070400000\nevent: heartbeat\nretry: #{Pubsubstub.reconnect_timeout}\ndata: ping\n\n"
        expect(last_response.body).to eq(message)
      end
    end
  end
end