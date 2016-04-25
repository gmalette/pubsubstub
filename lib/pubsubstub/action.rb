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
  end
end
