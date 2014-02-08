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
    PusherMsg.perform_async(pusher_channel, "c", FastJson.dump_one(self, false))
  end

  def pusher_update
    return if skip_pusher
    unless fields = self.class.try(:json_fields)
      serializer = Object.const_get("#{self.class.name}Serializer")
      fields = serializer.new(self, root: false).as_json.keys
    end
    upd = changes.reject { |k,v| !fields.include? k.to_sym }
    len = upd.keys.reject { |k, v| %w(created_at updated_at).include? k }.count
    return unless len > 0
    puts "#{self.class.name}##{self.id}: #{upd.inspect}"
    PusherMsg.perform_async(pusher_channel, "u", {id: id, changes: upd})
  end

  def pusher_delete
    return if skip_pusher
    PusherMsg.perform_async(pusher_channel, "d", self.id)
  end

  def pusher_channel
    raise 'You should implement pusher_channel method'
  end
end
