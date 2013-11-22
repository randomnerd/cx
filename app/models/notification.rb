class Notification < ActiveRecord::Base
  belongs_to :user
  scope :recent, -> { order('created_at desc').limit(50) }
  scope :user, -> uid { where('ask_user_id = ? or bid_user_id = ?', uid, uid) }
  scope :unack, -> { where(ack: false) }

  include PusherSync
  def pusher_channel
    "private-notifications-#{self.user_id}"
  end

end
