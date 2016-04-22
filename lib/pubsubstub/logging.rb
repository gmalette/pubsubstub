module Pubsubstub
  module Logging
    def error
      Pubsubstub.logger.error { "[#{self.class.name}] #{yield}" }
    end

    def info
      Pubsubstub.logger.info { "[#{self.class.name}] #{yield}" }
    end

    def debug
      Pubsubstub.logger.debug { "[#{self.class.name}] #{yield}" }
    end
  end
end
