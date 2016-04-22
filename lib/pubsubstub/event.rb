module Pubsubstub
  class Event
    attr_reader :id, :name, :data, :retry_after

    def initialize(data, options = {})
      @id = options[:id] || time_now
      @name = options[:name]
      @retry_after = options[:retry_after]
      @data = data
    end

    def to_json
      {id: @id, name: @name, data: @data, retry_after: @retry_after}.to_json
    end

    def to_message
      @message ||= build_message
    end

    def self.from_json(json)
      hash = JSON.load(json)
      new(hash['data'], name: hash['name'], id: hash['id'], retry_after: hash['retry_after'])
    end

    def ==(other)
      id == other.id && name == other.name && data == other.data && retry_after == other.retry_after
    end

    private

    def build_message
      data = @data.lines.map{ |segment| "data: #{segment}" }.join("\n".freeze)
      message = "id: #{id}\n"
      message << "event: #{name}\n" if name
      message << "retry: #{retry_after}\n" if retry_after
      message << data << "\n\n"
      message
    end

    def time_now
      (Time.now.to_f * 1000).to_i
    end
  end
end
