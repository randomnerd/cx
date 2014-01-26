class WorkerStat < ActiveRecord::Base
  belongs_to :worker
  belongs_to :currency
  has_one :user, through: :worker

  scope :active, -> {
    where('worker_stats.updated_at > ?', 5.minutes.ago)
  }
  scope :currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
end
