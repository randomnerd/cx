class Withdrawal < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  has_one :balance_change, as: :subject

  scope :unprocessed, -> { where(processed: false, failed: false) }

  before_create :check_amounts, :check_balance
  after_create :lock_funds

  def balance
    self.user.balance_for(self.currency_id)
  end

  def check_amounts
    return if self.amount.to_f / 10 ** 8 >= 0.01
    errors.add(:amount, "too%20low")
  end

  def check_balance
    balance = user.balance_for(self.currency_id)
    return if balance.amount >= self.amount
    errors.add(:amount, "greater%20than%20balance")
  end

  def lock_funds
    balance = user.balance_for(self.currency_id)
    balance.lock_funds(self.amount, self)
  end
end
