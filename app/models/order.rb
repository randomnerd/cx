class Order < ActiveRecord::Base
  validate :enough_balance, on: :create
  validate :filled_in_bound, on: :update
  validate :check_order_count, on: :create
  validate :check_amounts, on: :create

  belongs_to :user
  belongs_to :trade_pair

  before_save :set_fee
  after_commit :process_async, on: :create

  scope :recent,   ->     { order('created_at desc').limit(50) }
  scope :active,   ->     { where(complete: false).where(cancelled: false) }
  scope :tp,       -> tp  { where(trade_pair_id: tp) }
  scope :bid,      -> b   { where(bid: b) }
  scope :bid_sort, -> b   { b ? order('rate asc') : order('rate desc') }

  scope :bid_rate, -> b, r {
    b ? where('rate <= ?', r) : where('rate >= ?', r)
  }
  scope :matches_for, -> o {
    s = active.tp(o.trade_pair_id).bid_rate(o.bid, o.rate)
    return s.bid(!o.bid).bid_sort(o.bid)
  }

  include PusherSync
  def pusher_channel
    "orders-#{self.trade_pair_id}"
  end

  def balance_changes
    BalanceChange.where(subject: self)
  end

  def set_fee
    self.fee = bid ? trade_pair.buy_fee : trade_pair.sell_fee
  end

  def process
    self.with_lock do
      return unless self.valid?
      return if complete? or cancelled
      fill_matches
    end
  end

  def process_async
    self.with_lock do
      return if complete? or cancelled
      unless lock_funds
        self.cancel(true)
        return false
      end
      ProcessOrders.perform_async(self.id) unless Rails.env.test?
    end
  end

  def balance
    @cid ||= bid ? trade_pair.market_id : trade_pair.currency_id
    @balance ||= user.balance_for(@cid)
  end

  def funds_amount
    @amt ||= bid ? unmatched_market_amount : unmatched_amount
  end

  def lock_funds
    balance.lock_funds(funds_amount, self)
  end

  def fill_matches
    Order.matches_for(self).each do |o|
      o.with_lock do
        self.reload
        o.reload
        unless balance.validate_amount(funds_amount) || lock_funds
          self.destroy
          raise 'bad balance'
        end
        break if self.complete? || self.cancelled
        next if o.complete? || o.cancelled

        o_amt  = unmatched_amount
        t_amt  = o.unmatched_amount
        # use their amount if it is less than ours
        amt    = o_amt > t_amt ? t_amt : o_amt
        # use min rate for bid, and max rate for ask
        t_rate = bid ? [rate, o.rate].min : [rate, o.rate].max

        Trade.create(
          bid:            bid,
          rate:           t_rate,
          amount:         amt,
          ask_id:         bid ? o.id : id,
          bid_id:         bid ? id : o.id,
          ask_user_id:    bid ? o.user_id : user_id,
          bid_user_id:    bid ? user_id : o.user_id,
          trade_pair_id:  trade_pair_id
        )
      end
    end
  end

  def trades
    if bid
      Trade.where(bid_id: id)
    else
      Trade.where(ask_id: id)
    end
  end

  def market_amount
    rate * amount / 10 ** 8
  end

  def unmatched_amount
    amount - filled
  end

  def unmatched_market_amount
    rate * unmatched_amount / 10 ** 8
  end

  def enough_balance
    cid = bid ? trade_pair.market_id : trade_pair.currency_id
    amt = bid ? market_amount : amount
    balance = user.balances.find_by_currency_id(cid)
    balance.verify!
    if balance.amount < amt
      errors.add(:amount, "insufficient funds, amount(#{amt}) balance(#{balance.amount})")
    end
  end

  def update_status(update_amount)
    self.with_lock do
      self.filled += update_amount
      self.complete = complete?
      save
      cancel(true) if !complete? && unmatched_market_amount <= 0
    end
  end

  def complete?
    unmatched_amount <= 0
  end

  def cancel(force = false)
    self.with_lock do
      self.reload
      return false if self.cancelled && !force
      return false if self.complete? && !force
      cid = bid ? trade_pair.market_id : trade_pair.currency_id
      amt = bid ? unmatched_market_amount : unmatched_amount
      return false unless user.balance_for(cid).unlock_funds(amt, self) || force
      update_attribute :cancelled, true
    end
  end

  def filled_in_bound
    return unless filled > amount
    errors.add(:filled, "cant fill% more than amount")
  end

  def check_order_count
    count = user.orders.active.bid(self.bid).tp(self.trade_pair_id).count
    return if count < 20
    errors.add(:id, "too much open orders")
  end

  def check_amounts
    return if amount.to_f / 10 ** 8 >= 0.01 && market_amount > 0
    errors.add(:amount, "too low")
  end
end
