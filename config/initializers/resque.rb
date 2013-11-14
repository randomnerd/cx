require 'resque/server'
require 'resque_scheduler/server'

Resque.redis = Redis::Namespace.new("resque_cx", :redis => Redis.new)

# hq/resque authentication
class WardenAuth < Rack::Auth::Basic
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
    unless env['warden'].user.try(:admin?)
      return [ 404,
        { 'Content-Type' => 'text/html' },
        [ File.read('public/404.html') ]
      ]
    end
  end
end

Resque::Server.use WardenAuth
