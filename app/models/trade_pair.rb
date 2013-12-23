class TradePair < ActiveRecord::Base
  has_many :chart_items
  has_many :trades
  has_many :orders
  belongs_to :currency
  belongs_to :market, class_name: 'Currency', foreign_key: 'market_id'
  scope :url_slug, -> slug { where(url_slug: slug)}
  scope :public, -> { where(public: true) }

  include PusherSync
  def pusher_channel
    "tradePairs"
  end
end
