module Pubsubstub
  class Application < Sinatra::Base
    use PublishAction
    use StreamAction
  end
end
