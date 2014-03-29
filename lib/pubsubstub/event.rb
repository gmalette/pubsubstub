module Pubsubstub
  class Event
    attr_reader :id, :name, :data

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
      "id: #{@id}\nevent: #{name}\n#{data}\n\n"
    end

    def self.from_json(json)
      hash = JSON.load(json)
      new(hash['id'], hash['name'], hash['data'])
    end
  end
end
