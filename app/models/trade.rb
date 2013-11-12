class Trade < ActiveRecord::Base
  belongs_to :ask_order, class_name: 'Order', foreign_key: 'ask_id'
  belongs_to :bid_order, class_name: 'Order', foreign_key: 'bid_id'
  belongs_to :ask_user, class_name: 'User', foreign_key: 'ask_user_id'
  belongs_to :bid_user, class_name: 'User', foreign_key: 'bid_user_id'
  belongs_to :trade_pair
  delegate :currency_id, to: :trade_pair
  delegate :market_id,   to: :trade_pair
  delegate :currency, to: :trade_pair
  delegate :market,   to: :trade_pair

  after_create :process, :update_chart_items, :push_update

  def market_amount
    rate * amount / 10 ** 8
  end

  def bid_market_amount
    bid_order.rate * amount / 10 ** 8
  end

  def unused_amount
    bid_market_amount - market_amount
  end

  def process
    self.destroy and return false if bid_order.complete? || ask_order.complete?
    self.destroy and return false unless amount > 0
    self.destroy and return false unless market_amount > 0
    self.destroy and return false unless bid_market_amount > 0
    process_funds
    update_orders
    update_stats
    notify_users
  end

  def push_update
    #stub
  end

  def process_funds
    fill_bid
    fill_ask
    return_unused
  end

  def fill_bid
    currency.incomes.create(
      amount:  bid_fee,
      subject: self
    ) if bid_fee > 0

    bid_user.balance_for(currency_id).add_funds(amount - bid_fee, self)
    bid_user.balance_for(market_id).unlock_funds(market_amount, self, false)
  end

  def fill_ask
    market.incomes.create(
      amount:  ask_fee,
      subject: self
    ) if ask_fee > 0

    ask_user.balance_for(market_id).add_funds(market_amount - ask_fee, self)
    ask_user.balance_for(currency_id).unlock_funds(amount, self, false)
  end

  def return_unused
    return unless unused_amount > 0
    bid_user.balance_for(market_id).unlock_funds(unused_amount, self)
  end

  def update_orders
    bid_order.update_status(amount)
    ask_order.update_status(amount)
  end

  def update_stats
    #stub
  end

  def notify_users
    #stub
  end

  def bid_fee
    (amount / 100 * (bid_order.fee || 0)).round
  end

  def ask_fee
    (amount / 100 * (ask_order.fee || 0)).round
  end

  def update_chart_items
    int  = ChartItem.group_interval
    time = Time.at((self.created_at.to_i/(int*60)).floor * int*60)
    rec  = ChartItem.where(time: time, trade_pair_id: self.trade_pair_id).first_or_create
    rec.o ||= 0
    rec.h ||= 0
    rec.l ||= 0
    rec.o = rec.o == 0 ? self.rate : rec.o
    rec.h = rec.h > self.rate ? rec.h : self.rate
    rec.l = (rec.l > 0 && rec.l < self.rate) ? rec.l : self.rate
    rec.c = self.rate
    rec.v += self.amount
    rec.save

    Pusher["chartItems-#{trade_pair_id}"].trigger_async('chartItem#update',
      ChartItemSerializer.new(rec, root: false))
  end
end
