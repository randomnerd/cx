class WorkerStat < ActiveRecord::Base
  belongs_to :worker
  belongs_to :currency

  scope :active, -> {
    where('worker_stats.updated_at > ?', 2.minutes.ago)
  }
  scope :currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
end
