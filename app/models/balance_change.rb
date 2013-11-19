class BalanceChange < ActiveRecord::Base
  has_one    :currency, through: :balance
  belongs_to :balance
  belongs_to :subject, polymorphic: true
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
  scope :changes_total, -> {
    where('balance_changes.amount != 0').
    where('balance_changes.subject_type != "Order" or balance_changes.subject_type is null')
  }

  include PusherSync
  def pusher_channel
    "private-balanceChanges-#{balance.user_id}"
  end

  def pusher_create
    return unless self.amount != 0
    return if self.subject_type == 'Order'
    Pusher[pusher_channel].trigger_async("#{pusher_name}#new", pusher_serialize)
  end
end
