class BalanceChange < ActiveRecord::Base
  has_one    :currency, through: :balance
  belongs_to :balance
  belongs_to :subject, polymorphic: true
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
  scope :changes_total, -> {
    where('balance_changes.amount + balance_changes.held != 0')
  }

  include PusherSync
  def pusher_channel
    "private-balanceChanges-#{balance.user_id}"
  end

  def pusher_create
    return unless self.amount + self.held != 0
    PusherMsg.perform_async(pusher_channel, "c", FastJson.dump_one(self, false))
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
