class Message < ActiveRecord::Base
  validate :valid_msg
  validate :account_old_enough
  belongs_to :user, touch: true
  before_create :set_system

  include PusherSync
  def pusher_channel
    "messages"
  end

  scope :recent, -> { includes(:user).order('created_at desc').limit(50) }

  def name
    user.try(:nickname)
  end

  def account_old_enough
    return if user.created_at < 3.days.ago
    errors.add(:user_id, 'account is not old enough')
  end

  def valid_msg
    return unless body.empty?
    errors.add(:body, 'empty')
  end

  def set_system
    self.system = true if self.user.admin?
  end

end
