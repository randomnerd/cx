class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  has_many :balance_changes

  include PusherSync
  def pusher_channel
    "private-balances-#{self.user_id}"
  end

  def rpc_account
    "user-#{self.user_id}"
  end

  scope :currency, -> id { where(currency_id: id) }

  def deposits
    user.deposits.where(currency_id: self.currency_id)
  end

  def withdrawals
    user.withdrawals.where(currency_id: self.currency_id)
  end

  def validate_held(amount)
    self.held + 10 >= amount
  end

  def add_funds(amount, subject, comment = nil)
    self.with_lock do
      increment :amount, amount
      balance_changes.create(
        subject:  subject,
        comment:  comment,
        amount:   amount,
        t_amount: self.amount,
        t_held:   self.held,
        created_at: subject.try(:updated_at) || Time.now.utc
      ) if save
    end
  end

  def take_funds(amount, subject, comment = nil)
    self.with_lock do
      self.verify!
      return false if self.amount < amount
      decrement :amount, amount
      balance_changes.create(
        subject:  subject,
        comment:  comment,
        amount:   -amount,
        t_amount: self.amount,
        t_held:   self.held,
        created_at: subject.try(:updated_at) || Time.now.utc
      ) if save
    end
  end


  def lock_funds(lock_amount, subject)
    self.with_lock do
      self.verify!
      return false if self.amount < lock_amount
      decrement :amount,  lock_amount
      increment :held,    lock_amount
      balance_changes.create(
        subject:  subject,
        amount:  -lock_amount,
        held:     lock_amount,
        t_amount: self.amount,
        t_held:   self.held,
        created_at: subject.try(:updated_at) || Time.now.utc
      ) if save
    end
  end

  def unlock_funds(unlock_amount, subject, move = true)
    self.with_lock do
      if self.held < unlock_amount
        return false if move
        negative = unlock_amount - self.held
        decrement :amount, negative
        decrement :held, unlock_amount - negative
        balance_changes.create(
          subject:  subject,
          amount:  -negative,
          held:    -(unlock_amount - negative),
          t_amount: self.amount,
          t_held:   self.held
        ) if save
      else
        increment :amount,  unlock_amount if move
        decrement :held,    unlock_amount
        balance_changes.create(
          subject:  subject,
          amount:   move ? unlock_amount : 0,
          held:    -unlock_amount,
          t_amount: self.amount,
          t_held:   self.held
        ) if save
      end
    end
  end

  def verify(detailed = false)
    v = balance_changes.select('sum(amount) as amount, sum(held) as held').group(:balance_id).order(:balance_id).first
    held = v.try(:held) || 0
    amount = v.try(:amount) || 0
    result = amount == self.amount && held == self.held
    if detailed
      return {
        held:        held.to_i,
        valid:       result,
        amount:      amount.to_i,
        held_diff:   (self.held - held).to_i,
        amount_diff: (self.amount - amount).to_i
      }
    else
      return result
    end
  end

  def verify_each!
    self.with_lock do
      held   = 0
      amount = 0
      self.balance_changes.order(:created_at).find_in_batches do |bcs|
        bcs.each do |bc|
          held   += bc.held
          amount += bc.amount
          bc.update_attributes t_amount: amount, t_held: held
        end
      end
      self.update_attributes amount: amount, held: held
    end
  end

  def verify!
    self.with_lock do
      v = self.verify(true)
      update_attributes(amount: v[:amount], held: v[:held]) unless v[:valid]
    end
  end

  def audit(force = false)
    self.with_lock do
      u = self.user
      b = self
      cid = b.currency_id

      allow_nils_with_comments = ['migrated balance', 'administrative adjustment', 'incomes for dumping']

      adj = b.balance_changes.where(comment: allow_nils_with_comments).sum(:amount).to_i
      deposits = u.deposits.where(processed: true, currency_id: cid).sum(:amount).to_i
      withdrawals = u.withdrawals.where(currency_id: cid).where('txid is not null').sum(:amount).to_i

      # if we ask on market pair, we earn
      ask_mkt_trades = u.trades.joins(:trade_pair).where(trade_pairs: {market_id: cid}, ask_user_id: u.id).map(&:market_amount).sum
      # if we bid on market pair, we spend
      bid_mkt_trades = u.trades.joins(:trade_pair).where(trade_pairs: {market_id: cid}, bid_user_id: u.id).map(&:market_amount).sum

      # if we ask on curr pair, we spend
      ask_trades = u.trades.joins(:trade_pair).where(trade_pairs: {currency_id: cid}, ask_user_id: u.id).sum(:amount)
      # if we bid on curr pair, we earn
      bid_trades = u.trades.joins(:trade_pair).where(trade_pairs: {currency_id: cid}, bid_user_id: u.id).sum(:amount)

      held = u.orders.active.joins(:trade_pair).where(bid: false, trade_pairs: {currency_id: cid}).map(&:unmatched_amount).sum
      held += u.orders.active.joins(:trade_pair).where(bid: true, trade_pairs: {market_id: cid}).map(&:unmatched_market_amount).sum

      mining = user.block_payouts.joins(:block).where(blocks: {currency_id: currency_id}, paid: true).map(&:reward_minus_fee).sum

      amount = adj + deposits - withdrawals + ask_mkt_trades + bid_trades - bid_mkt_trades - ask_trades + mining
      update_attributes(amount: amount.to_i - held, held: held) if force
      { amount: amount.to_i, held: held }
    end
  end

  def rework
    self.with_lock do

      balance_changes.where(subject_id: nil).
      where('comment not in (?)', ['migrated balance', 'incomes for dumping']).
      delete_all

      verify!

      actions = []
      amt = balance_changes.first.try(:amount) || 0
      held = 0

      user.deposits.where(processed: true, currency_id: currency_id).each do |d|
        actions << [:add_funds, d.amount, d]
        amt += d.amount
      end

      user.withdrawals.where(currency_id: currency_id).where('txid is not null').each do |w|
        actions << [:add_funds, -w.amount, w]
        amt -= w.amount
      end

      user.trades.joins(:trade_pair).
      where(trade_pairs: {market_id: currency_id}, ask_user_id: user_id).each do |t|
        actions << [:add_funds, t.market_amount, t]
        amt += t.market_amount
      end

      user.trades.joins(:trade_pair).
      where(trade_pairs: {market_id: currency_id}, bid_user_id: user_id).each do |t|
        actions << [:add_funds, -t.market_amount, t]
        amt -= t.market_amount
      end

      user.trades.joins(:trade_pair).
      where(trade_pairs: {currency_id: currency_id}, ask_user_id: user_id).each do |t|
        actions << [:add_funds, -t.amount, t]
        amt -= t.amount
      end

      user.trades.joins(:trade_pair).
      where(trade_pairs: {currency_id: currency_id}, bid_user_id: user_id).each do |t|
        actions << [:add_funds, t.amount, t]
        amt += t.amount
      end

      user.orders.active.joins(:trade_pair).where(bid: false, trade_pairs: {currency_id: currency_id}).each do |o|
        actions << [:lock_funds, o.unmatched_amount, o]
        held += o.unmatched_amount
      end

      user.orders.active.joins(:trade_pair).where(bid: true, trade_pairs: {market_id: currency_id}).each do |o|
        actions << [:lock_funds, o.unmatched_market_amount, o]
        held += o.unmatched_market_amount
      end

      user.block_payouts.joins(:block).where(blocks: {currency_id: currency_id}, paid: true).each do |payout|
        actions << [:add_funds, payout.reward_minus_fee, payout]
      end

      actions.sort! { |x,y| x.last.created_at <=> y.last.created_at }
      actions.each do |a|
        method, amount, subject = a
        self.send(method, amount, subject)
      end

      { amount: amt, held: held }
    end
  end
end
