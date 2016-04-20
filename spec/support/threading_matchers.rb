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
