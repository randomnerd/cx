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

  def process
    self.with_lock do
      begin
        balance = self.balance
        b = balance.balance_changes.where('id != ?', self.balance_change.id).sum(:amount)
        raise 'balance is too low' if b < self.amount
        account = balance.rpc_account
        amount  = (self.amount.to_f / 10 ** 8) - (self.tx_fee || 0).to_f
        move    = self.rpc.move '', account, amount
        raise 'unable to move funds' unless move
        txid    = self.rpc.sendfrom account, self.address, amount
        raise 'sendfrom failed' unless txid
        self.processed = true
        self.txid = txid
        self.user.notifications.create(
          title: "#{self.name} withdrawal processed",
          body: "#{n2f self.amount} #{self.name} sent to #{self.address}"
        )
      rescue => e
        # balance.add_funds(self.amount, self)
        self.failed = true
        puts e.inspect
        puts e.backtrace
        # self.user.notifications.create(
        #   title: "#{self.name} self failed",
        #   body: "#{n2f self.amount} #{self.name} were credited back to your account"
        # )
      ensure
        self.save
        return unless self.balance_change
        self.balance_change.touch
        self.balance_change.pusher_update
      end
    end

  end
end
