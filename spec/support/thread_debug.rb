# frozen_string_literal: true

def print_threads
  puts '>> print_threads'
  Thread.list.each do |thread|
    p thread
    puts "Thread TID-#{(thread.object_id ^ ::Process.pid).to_s(36)} #{thread['label']}"
    if thread.backtrace
      puts thread.backtrace.join("\n")
    else
      puts "<no backtrace available>"
    end
  end
end

def handle_signal(sig)
  case sig
  when 'TTIN'
    print_threads
  end
end

%w(TTIN).each do |sig|
  begin
    trap sig do
      puts "Signal #{sig}"
      handle_signal(sig)
    end
  rescue ArgumentError
    puts "Signal #{sig} not supported"
  end
end
