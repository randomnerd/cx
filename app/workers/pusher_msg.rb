class PusherMsg
  include Sidekiq::Worker

  def perform(channel, event, message)
    # Pusher[channel].trigger event, message
  end
end
