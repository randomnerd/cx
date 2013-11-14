class Withdrawal < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency

  scope :unprocessed, -> { where(processed: false, failed: false) }

  def balance
    self.user.balance_for(self.currency_id)
  end
end
