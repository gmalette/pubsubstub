module Pubsubstub
  class PublishAction < Pubsubstub::Action
    post '/' do
      event = Event.new(params[:data], name: params[:event])
      (params[:channels] || [:default]).each do |channel_name|
        channel(channel_name).publish(event)
      end
      ""
    end
  end
end
