module Pubsubstub
  class PublishAction
    def initialize(*)
    end

    def call(env)
      request = Rack::Request.new(env)
      channels = (request.params['channels'] || [:default]).each do |channel_name|
        Pubsubstub.publish(channel_name, request.params['data'], name: request.params['event'])
      end
      [200, {}, ['']]
    end
  end
end
