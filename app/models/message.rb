class Message < ActiveRecord::Base
  validate :valid_msg
  belongs_to :user, touch: true

  include PusherSync
  def pusher_channel
    "messages"
  end

  scope :recent, -> { includes(:user).order('created_at desc').limit(50) }

  def name
    user.nickname
  end

  def valid_msg
    return unless body.empty?
    errors.add(:body, 'empty')
  end

end
