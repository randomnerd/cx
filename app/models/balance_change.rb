class BalanceChange < ActiveRecord::Base
  has_one    :currency, through: :balance
  belongs_to :balance
  belongs_to :subject, polymorphic: true
  before_save :compile_comment
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
  scope :changes_total, -> {
    where('balance_changes.amount + balance_changes.held != 0')
  }

  include ApplicationHelper
  include PusherSync
  def pusher_channel
    "private-balanceChanges-#{balance.user_id}"
  end

  def pusher_create
    return unless self.amount + self.held != 0
    PusherMsg.perform_async(pusher_channel, "c", BalanceChangeSerializer.new(self))
  end

  def compile_comment
    return unless subject
    case subject.class.name
    when 'Trade'
      if amount > 0
        act = currency.id == subject.trade_pair.market_id ? 'Sold' : 'Bought'
      else
        act = currency.id == subject.trade_pair.market_id ? 'Bought' : 'Sold'
      end
      c = "#{act} #{n2f subject.amount} #{subject.currency.name} " +
          "@ #{n2f subject.rate} #{subject.market.name} each " +
          "| #{n2f subject.market_amount} #{subject.market.name} "
    when 'BlockPayout'
      c = "Mining reward for block ##{subject.block.number} " +
          "| #{n2f subject.reward_minus_fee} #{currency.name}"
    when 'Withdrawal'
      c = "Withdrawal | #{n2f amount.abs} #{currency.name}"
    when 'Deposit'
      c = "Deposit | #{n2f amount.abs} #{currency.name}"
    end
    self.comment = c
  end

  def prev
    balance.balance_changes.where('created_at < ?', self.created_at).last
  end

  def prev_st
    balance.balance_changes.where(subject: self.subject).
    where('created_at < ?', self.created_at).last
  end

  def next
    balance.balance_changes.where('created_at > ?', self.created_at).first
  end

  def next_st
    balance.balance_changes.where(subject: self.subject).
    where('created_at > ?', self.created_at).first
  end

end
