class Withdrawal < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :user
  belongs_to :currency
  has_one :balance_change, as: :subject

  scope :unprocessed, -> { where(processed: false, failed: false) }

  validate :check_amounts, on: :create
  validate :check_balance, on: :create
  after_commit :process_async, on: :create

  def balance
    self.user.balance_for(self.currency_id)
  end

  def verify(skip = 0, batch = 50)
    return if self.created_at > 10.minutes.ago
    acc = "user-#{self.user_id}"
    amt = (self.amount.to_f / 10 ** 8) - (self.currency.tx_fee || 0).to_f
    txs = self.currency.listtransactions(acc, batch, skip)
    txs.reverse.each do |tx|
      next if Withdrawal.find_by_txid(tx['txid'])
      next unless tx['amount'] == amt
      self.failed = false
      self.processed = true
      self.txid = tx['txid']
      self.save(validate: false)
      return true
    end
    if txs.count < 50
      self.balance.add_funds(self.amount, self)
      return false
    else
      self.verify(skip+batch, batch)
    end
  end

  def check_amounts
    return if self.amount.to_f / 10 ** 8 >= 0.01
    errors.add(:amount, "Minimum withdrawal is 0.01")
  end

  def check_balance
    balance.verify!
    return if balance.amount >= self.amount
    errors.add(:amount, "Balance is too low")
  end

  def process_async
    return if self.processed or self.failed
    ProcessWithdrawals.perform_async(self.id)
  end

  def process
    self.with_lock do
      self.reload
      return if self.processed or self.failed
      return unless self.valid?
      begin
        raise 'failed to take funds' unless balance.take_funds(self.amount, self)
        account = balance.rpc_account
        amount  = (self.amount.to_f / 10 ** 8) - (currency.tx_fee || 0).to_f
        move    = currency.rpc.move '', account, amount
        raise 'unable to move funds' unless move
        txid    = currency.rpc.sendfrom account, self.address, amount
        raise 'sendfrom failed' unless txid
        self.processed = true
        self.txid = txid
        self.user.notifications.create(
          title: "#{currency.name} withdrawal processed",
          body: "#{n2f self.amount} #{currency.name} sent to #{self.address}"
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
        self.save(validate: false)
        return unless self.balance_change
        self.balance_change.touch
        self.balance_change.pusher_update
      end
    end

  end
end
