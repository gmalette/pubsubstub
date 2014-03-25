require "sinatra"
require "em-hiredis"
require "pubsubstub/version"

module Pubsubstub
  module RedisPubSub
    def pub
      @pub ||= redis_connection
    end

    def sub
      @sub ||= redis_connection
    end

    private
    def redis_connection
      EM::Hiredis.connect(ENV['REDIS_URL'] || "redis://localhost:6379")
    end
  end

  class Application < Sinatra::Base
    extend RedisPubSub
    get '/' do

    end

    post '/' do

    end
  end
end
