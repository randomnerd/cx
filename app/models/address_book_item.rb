class AddressBookItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency

  include PusherSync
  def pusher_channel
    "private-addressBook-#{self.user_id}"
  end

end
