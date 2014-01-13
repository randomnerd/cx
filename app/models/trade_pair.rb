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

  def order_book(bid = true)
    orders.active.bid(bid).
    bid_sort(!bid).group(:rate).
    select('rate, sum(amount) as amount, (sum(amount-filled)*rate)/pow(10,8) as market_amount').
    map {|o| [o.rate, o.amount, o.market_amount.round]}
  end

  def avg_bid_rate(cap = 0.2)
    t_amt = 0
    t_mkt_amt = 0
    order_book.each do |item|
      rate, amount, market_amount = item
      t_amt += amount
      t_mkt_amt += market_amount
      break if t_mkt_amt.to_f/10**8 >= cap
    end

    return 0 if t_amt == 0
    (t_mkt_amt / t_amt).round(8).to_f
  end
end
