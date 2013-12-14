# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 12)
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

  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }
end
