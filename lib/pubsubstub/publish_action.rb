module Pubsubstub
  class PublishAction < Pubsubstub::Action
    post '/' do
      (params[:channels] || [:default]).each do |channel_name|
        Pubsubstub.publish(channel_name).publish(params[:data], name: params[:event])
      end
      ""
    end
  end
end
