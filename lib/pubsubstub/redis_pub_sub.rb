module Pubsubstub
  class RedisPubSub
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
end
