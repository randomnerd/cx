class AddressBookItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency

  include PusherSync
  def pusher_channel
    "private-addressBook-#{self.user_id}"
  end

  def self.json_fields
    [:id, :name, :address, :updated_at, :created_at, :user_id, :currency_id]
  end

  def as_json(options = {})
    super(options.merge(only: self.class.json_fields))
  end
end
