class PusherMsg
  include Sidekiq::Worker
  sidekiq_options queue: :pusher, retry: false

  def perform(channel, event, message)
    sleep 0.2
    Pusher[channel].trigger event, message
  end
end
