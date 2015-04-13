module Pubsubstub
  class << self
    attr_accessor :heartbeat_frequency
  end
  self.heartbeat_frequency = 15

  class Application < Sinatra::Base

    use PublishAction
    use StreamAction
  end
end
