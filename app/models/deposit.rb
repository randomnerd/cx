class Deposit < ActiveRecord::Base
  belongs_to :user
  belongs_to :wallet
  belongs_to :currency
  has_one :balance_change, as: :subject

  scope :unprocessed, -> { where(processed: false) }
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }

  validate :check_duplicates, on: :create

  def check_duplicates
    return unless user.deposits.find_by_txid(self.txid)
    errors.add(:txid, 'Duplicate deposit!')
  end

  include PusherSync
  def pusher_channel
    "private-deposits-#{self.user_id}"
  end
end
