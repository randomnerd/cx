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
    PusherMsg.perform_async(pusher_channel, "c", pusher_serialize)
  end
end
