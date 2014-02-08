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

  def order_book(bid, bid_flag = false, limit = 20)
    book = orders.active.bid(bid).bid_sort(!bid).group(:rate).limit(20).
    select(:rate, 'sum(amount-filled) as amount').
    map do |item|
      hash = { rate: item.rate, amount: item.amount.to_i }
      hash[:bid] = bid if bid_flag
      hash
    end
  end

  def order_book_both
    order_book(false, true) + order_book(true, true)
  end

  def avg_bid_rate(cap = 0.2)
    t_amt = 0
    t_mkt_amt = 0
    order_book(true).each do |item|
      t_amt += item[:amount]
      t_mkt_amt += (item[:rate] * item[:amount]).to_f / 10**8
      break if t_mkt_amt.to_f/10**8 >= cap
    end

    return 0 if t_amt == 0
    (t_mkt_amt / t_amt).round(8).to_f
  end

  def self.json_fields
    [:id, :buy_fee, :sell_fee, :last_price, :currency_id, :market_id,
             :url_slug, :rate_min, :rate_max, :currency_volume,
             :market_volume, :updated_at]
  end

  def as_json(options = {})
    super(options.merge(only: self.class.json_fields))
  end
end
