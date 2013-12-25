module PusherSync
  def self.included(base)
    return if Rails.env.test?
    base.after_create  :pusher_create
    base.after_update  :pusher_update
    base.after_destroy :pusher_delete
  end

  def pusher_serialize
    o = Object.const_get("#{self.class.name}Serializer")
    o.try(:new, self, root: false).to_json || self.to_json
  end

  def pusher_name
    self.class.name.downcase
  end

  def pusher_create
    return if Rails.cache.read('stop_pusher')
    PusherMsg.perform_async(pusher_channel, "c", pusher_serialize)
  end

  def pusher_update
    return if Rails.cache.read('stop_pusher')
    PusherMsg.perform_async(pusher_channel, "u", pusher_serialize)
  end

  def pusher_delete
    return if Rails.cache.read('stop_pusher')
    PusherMsg.perform_async(pusher_channel, "d", pusher_serialize)
  end

  def pusher_channel
    raise 'You should implement pusher_channel method'
  end
end
