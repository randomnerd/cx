class BalanceChange < ActiveRecord::Base
  belongs_to :balance
  belongs_to :subject, polymorphic: true

  include PusherSync
  def pusher_channel
    "private-balanceChanges-#{balance.user_id}"
  end
end
