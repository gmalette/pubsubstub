module Pubsubstub
  class Application
    def initialize(*)
      @publish = PublishAction.new
      @stream = StreamAction.new
    end

    def self.call(env)
      @instance ||= new
      @instance.call(env)
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.get?
        @stream.call(env)
      else
        @publish.call(env)
      end
    end
  end
end
