RSpec::Matchers.define :complete do
  match do |thread|
    thread.join(@wait_time) == thread
  end

  chain :in_under do |seconds|
    @wait_time = seconds
  end

  failure_message do |thread|
    "expected that thread to complete but it didn't (status=#{thread.status.inspect})"
  end
end

RSpec::Matchers.define :happen do
  match do |condition|
    success = false
    @wait_time ||= 0.1
    until @wait_time < 0
      @wait_time -= 0.05
      break if success = condition.call
      sleep 0.05
    end
    success
  end

  supports_block_expectations

  chain :in_under do |seconds|
    @wait_time = seconds
  end
end

RSpec::Matchers.define :listen do
  match do |port|
    start = Time.now.to_f
    begin
      connection = TCPSocket.new('localhost', port)
      true
    rescue
      if (Time.now.to_f - start) < @wait_time
        retry
      else
        false
      end
    ensure
      connection.close if connection
    end
  end

  chain :in_under do |seconds|
    @wait_time = seconds
  end

  failure_message do |port|
    "expected port #{port} to listen to connection but it didn't"
  end
end
