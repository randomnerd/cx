class TradePair < ActiveRecord::Base
  has_many :chart_items
  has_many :trades
  has_many :orders
  belongs_to :currency
  belongs_to :market, class_name: 'Currency', foreign_key: 'market_id'
  scope :url_slug, -> slug { where(url_slug: slug)}

  after_create :push_create
  after_update :push_update
  after_destroy :push_delete

  def push_create
    Pusher["tradePairs"].trigger_async('tradePair#new',
      TradePairSerializer.new(self, root: false))
  end

  def push_update
    Pusher["tradePairs"].trigger_async('tradePair#update',
      TradePairSerializer.new(self, root: false))
  end

  def push_delete
    Pusher["tradePairs"].trigger_async('tradePair#delete',
      TrderSerializer.new(self, root: false))
  end
end
