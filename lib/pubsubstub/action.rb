module Pubsubstub
  class Action < Sinatra::Base
    configure :production, :development do
      enable :logging
    end

    configure :test do
      set :dump_errors, false
      set :raise_errors, true
      set :show_exceptions, false
    end

    def initialize(*)
      @channels = Hash.new { |h, k| h[k] = Channel.new(k) }
      @connections = []
      super
    end

    def channel(name)
      @channels[name]
    end
  end
end
