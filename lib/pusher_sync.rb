module PusherSync
   def self.included(base)
    base.after_create :pusher_create
    base.after_update :pusher_update
    base.after_destroy :pusher_delete
  end

  def pusher_serialize
    o = Object.const_get("#{self.class.name}Serializer")
    o.try(:new, self, root: false) || self
  end

  def pusher_name
    self.class.name.downcase
  end

  def pusher_create
    Pusher[pusher_channel].trigger_async("#{pusher_name}#new", pusher_serialize)
  end

  def pusher_update
    Pusher[pusher_channel].trigger_async("#{pusher_name}#update", pusher_serialize)
  end

  def pusher_delete
    Pusher[pusher_channel].trigger_async("#{pusher_name}#delete", pusher_serialize)
  end

  def pusher_channel
    raise 'You should implement pusher_channel method'
  end
end
