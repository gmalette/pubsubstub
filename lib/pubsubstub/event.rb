module Pubsubstub
  class Event
    def initialize(id, name, data)
      @id = id
      @name = name
      @data = data
    end

    def to_json
      {id: @id, name: @name, data: @data}.to_json
    end

    def to_message
      data = @data.split("\n").map{ |segment| "data: #{segment}" }.join("\n")
      "id: #{@id}\nevent: #{@name}\n#{data}\n\n"
    end
  end
end
