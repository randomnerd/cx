class Worker < ActiveRecord::Base
  belongs_to :user
  has_many :worker_stats
  validates_presence_of :name, :pass
  validates_uniqueness_of :name
  validate :worker_count_limit

  include PusherSync

  def pusher_channel
    "private-workers-#{self.user_id}"
  end

  def worker_count_limit
    return if user.workers.count < 20
    errors.add(:id, 'Too much workers for account')
  end
end
