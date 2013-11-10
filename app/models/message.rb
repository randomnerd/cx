class Message < ActiveRecord::Base
  validate :valid_msg
  belongs_to :user, touch: true
  after_create :push_create

  scope :recent, -> { includes(:user).order('created_at desc').limit(50) }

  def name
    user.nickname
  end

  def broadcast
    Pusher['chat'].trigger_async('msg', {
      time: created_at.to_i,
      name: name,
      body: body
    })
  end

  def valid_msg
    return unless body.empty?
    errors.add(:body, 'empty')
  end

  def push_create
    Pusher["messages"].trigger_async('message#new',
      MessageSerializer.new(self, root: false))
  end
end
