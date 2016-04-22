module Pubsubstub
  module Logging
    def info
      Pubsubstub.logger.info { "[#{self.class.name}] #{yield}" }
    end

    def debug
      Pubsubstub.logger.debug { "[#{self.class.name}] #{yield}" }
    end
  end
end
