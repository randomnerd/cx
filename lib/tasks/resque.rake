require 'resque_scheduler/tasks'

# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
task "resque:setup" => :environment do
  require 'resque'
  require 'resque_scheduler'
  require 'resque/scheduler'
  Resque.schedule = YAML.load_file(File.expand_path('schedule.yml', 'config'))
end

task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  # and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
    Resque.redis.client.reconnect
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
end
