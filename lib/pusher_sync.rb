module PusherSync
  def self.included(base)
    return if Rails.env.test?
    base.after_create  :pusher_create
    base.after_update  :pusher_update
    base.after_destroy :pusher_delete
  end

  def pusher_name
    self.class.name.downcase
  end

  def pusher_create
    return if Rails.cache.read('stop_pusher')
    PusherMsg.perform_async(pusher_channel, "c", FastJson.dump_one(self, false))
  end

  def pusher_update
    return if Rails.cache.read('stop_pusher')
    PusherMsg.perform_async(pusher_channel, "u", FastJson.dump_one(self, false))
  end

  def pusher_delete
    return if Rails.cache.read('stop_pusher')
    PusherMsg.perform_async(pusher_channel, "d", FastJson.dump_one(self, false))
  end

  def pusher_channel
    raise 'You should implement pusher_channel method'
  end
end
