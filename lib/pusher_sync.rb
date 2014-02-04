module PusherSync
  def self.included(base)
    return if Rails.env.test?
    base.send(:attr_accessor, :skip_pusher)
    base.after_create  :pusher_create
    base.after_update  :pusher_update
    base.after_destroy :pusher_delete
  end

  def pusher_name
    self.class.name.downcase
  end

  def pusher_create
    return if skip_pusher
    PusherMsg.perform_async(pusher_channel, "c", self.as_json)
  end

  def pusher_update
    return if skip_pusher
    PusherMsg.perform_async(pusher_channel, "u", self.as_json)
  end

  def pusher_delete
    return if skip_pusher
    PusherMsg.perform_async(pusher_channel, "d", self.as_json)
  end

  def pusher_channel
    raise 'You should implement pusher_channel method'
  end
end
