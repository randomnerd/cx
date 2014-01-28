set :application, 'cx'
set :repo_url, 'git@github.com:erundook/cx.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/cx'
set :scm, :git

set :local_repository, "file://."
set :deploy_via, :copy
set :copy_cache, true
set :copy_via, :scp

# set :format, :pretty
# set :log_level, :debug
set :pty, true

set :clockwork_config, "#{current_path}/config/clockwork.rb"

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :sidekiq_pid, "tmp/pids/sidekiq.pid"

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

SSHKit.config.command_map[:rake]  = "bundle exec rake"
SSHKit.config.command_map[:rails] = "bundle exec rails"

namespace :clockwork do
  desc "Start clockwork daemon"
  task :start do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} jruby -S clockworkd -c #{fetch(:clockwork_config)} --pid-dir tmp/pids -d #{current_path} --log start"
    end
  end

  desc "Stop clockwork daemon"
  task :stop do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} jruby -S clockworkd -c #{fetch(:clockwork_config)} --pid-dir tmp/pids -d #{current_path} --log stop"
    end
  end

  desc "Restart clockwork daemon"
  task :restart do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} jruby -S clockworkd -c #{fetch(:clockwork_config)} --pid-dir tmp/pids -d #{current_path} --log restart"
    end
  end
end
