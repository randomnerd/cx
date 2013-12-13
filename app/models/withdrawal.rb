class Withdrawal < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  has_one :balance_change, as: :subject

  scope :unprocessed, -> { where(processed: false, failed: false) }

  validate :check_amounts
  validate :check_balance
  after_commit :lock_funds, on: :create

  def balance
    self.user.balance_for(self.currency_id)
  end

  def check_amounts
    return if self.amount.to_f / 10 ** 8 >= 0.01
    errors.add(:amount, "Minimum withdrawal is 0.01")
  end

  def check_balance
    balance = user.balance_for(self.currency_id)
    balance.verify!
    return if balance.amount >= self.amount
    errors.add(:amount, "Balance is too low")
  end

  def lock_funds
    balance = user.balance_for(self.currency_id)
    balance.add_funds(-self.amount, self)
  end
end
