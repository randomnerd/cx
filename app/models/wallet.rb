class Wallet < ActiveRecord::Base
  validate :generate_address

  belongs_to :user
  belongs_to :currency
  has_many :deposits
  has_many :withdrawals

  after_commit :set_balance_address, on: :create

  def generate_address
    self.address ||= currency.rpc.getnewaddress "user-#{self.user_id}"
    return if self.address
    errors.add(:address, 'Empty')
  end

  def set_balance_address
    balance = self.user.balance_for(self.currency_id)
    balance.update_attribute :deposit_address, self.address
  end
end
