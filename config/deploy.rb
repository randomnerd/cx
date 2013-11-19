set :application, 'cx'
set :repo_url, 'git@github.com:erundook/cx.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/cx'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
set :pty, true

set :unicorn_binary, "#{shared_path}/bin/unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid,    "#{shared_path}/tmp/pids/unicorn.pid"
set :resque_pid,     "#{shared_path}/tmp/pids/resque.pid"

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

SSHKit.config.command_map[:rake]  = "bundle exec rake"
SSHKit.config.command_map[:rails] = "bundle exec rails"


namespace :deploy do
  desc "Start application"
  task :start do
    on roles(:app) do
      execute "cd #{current_path} && #{fetch(:unicorn_binary)} -c #{fetch(:unicorn_config)} -E #{fetch(:rails_env, "production")} -D"
    end
  end

  desc 'Stop resque pool'
  task :stop_resque do
    on roles(:resque) do
      execute "kill `cat #{fetch(:resque_pid)}`"
    end
  end

  desc 'Start resque pool'
  task :start_resque do
    on roles(:resque) do
      execute "cd #{current_path} && bundle exec resque-pool -E #{fetch(:rails_env, "production")} -p #{fetch(:resque_pid)} -d"
    end
  end

  desc 'Restart resque pool'
  task :restart_resque do
    invoke 'deploy:stop_resque'
    sleep 3
    invoke 'deploy:start_resque'
  end

  desc "Stop application"
  task :stop do
    on roles(:app) do
      execute "kill `cat #{fetch(:unicorn_pid)}`"
    end
  end

  desc "Gracefully stop application"
  task :graceful_stop do
    on roles(:app) do
      execute "kill -s QUIT `cat #{fetch(:unicorn_pid)}`"
    end
  end

  desc "Reload the application"
  task :reload do
    on roles(:app) do
      execute "kill -s USR2 `cat #{fetch(:unicorn_pid)}`"
    end
  end

  desc 'Restart application'
  task :restart do
    invoke 'deploy:stop'
    sleep 10
    invoke 'deploy:start'
  end

  after :finishing, 'deploy:cleanup', 'bundle:install', 'deploy:restart_resque'

end
