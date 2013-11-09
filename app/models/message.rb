class Message < ActiveRecord::Base
  belongs_to :user, touch: true
  after_create :broadcast

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
end
