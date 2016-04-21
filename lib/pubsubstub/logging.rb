module Pubsubstub
  module Logging
    def info
      Pubsubstub.logger.debug { "[#{self.class.name}] #{yield}" }
    end

    def debug
      Pubsubstub.logger.debug { "[#{self.class.name}] #{yield}" }
    end
  end
end