# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 12)
timeout 15
preload_app true
pid 'tmp/pids/unicorn.pid'
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

GC.respond_to?(:copy_on_write_friendly=) and
 GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

   old_pid = "#{server.config[:pid]}.oldbin"
   if old_pid != server.pid
      begin
         sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
         Process.kill(sig, File.read(old_pid).to_i)
      rescue Errno::ENOENT, Errno::ESRCH
      end
   end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
