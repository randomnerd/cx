class Message < ActiveRecord::Base
  validate :user_not_banned, on: :create
  validate :valid_msg
  validate :account_old_enough, on: :create
  belongs_to :user
  before_create :set_system

  include ActionView::Helpers::DateHelper
  include PusherSync
  def pusher_channel
    "messages"
  end

  scope :recent, -> { order('messages.created_at desc').limit(50) }

  def user_not_banned
    return unless user.banned?
    expires = time_ago_in_words(user.banned_until)
    errors.add(:user_id, "Banned, ban expires in #{expires}")
  end

  def account_old_enough
    return if user.created_at < 3.days.ago
    expires = time_ago_in_words(user.created_at + 3.days)
    errors.add(:user_id, "Account should be at least 3 days old (#{expires} remaining)")
  end

  def valid_msg
    return unless body.empty?
    errors.add(:body, 'empty')
  end

  def set_system
    self.name = self.user.nickname
    self.system = true if self.user.admin?
  end

  def self.json_fields
    [:id, :body, :created_at, :updated_at, :system, :name]
  end

  def as_json(options = {})
    super(options.merge(only: self.class.json_fields))
  end
end
