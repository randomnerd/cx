# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 4)
timeout 15
preload_app true
pid 'tmp/pids/unicorn.pid'

GC.respond_to?(:copy_on_write_friendly=) and
 GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # eventmachine fix
  if defined?(EventMachine)
    unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
      if EventMachine.reactor_running?
        EventMachine.stop_event_loop
        EventMachine.release_machine
        EventMachine.instance_variable_set("@reactor_running",false)
      end
      Thread.new { EventMachine.run }
    end
  end

  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }
end
