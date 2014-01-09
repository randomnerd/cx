class Withdrawal < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :user
  belongs_to :currency
  has_one :balance_change, as: :subject

  scope :unprocessed, -> { where(processed: false, failed: false) }
  scope :not_sent, -> { where(txid: nil, cancelled: false) }

  validate :check_amounts
  validate :check_blocked_withdrawals
  validate :check_balance, on: :create
  after_commit :process_async, on: :create
  validate :production?

  def check_blocked_withdrawals
    return unless user.block_withdrawals
    errors.add :user_id, 'Withdrawals are blocked for this user'
  end

  def self.verify_all
    not_sent.each &:verify
  end

  def production?
    return if Rails.env.production?
    errors.add(:id, 'Not in production environment')
  end

  def balance
    self.user.balance_for(self.currency_id)
  end

  def balance_changes
    BalanceChange.where(subject: self)
  end

  def check_address
    info = self.currency.rpc.validateaddress self.address
    !!info.try(:[], 'isvalid')
  rescue
    false
  end

  def verify(skip = 0, batch = 50)
    self.with_lock do
      unless self.user
        self.destroy
        return
      end

      puts self.inspect

      funds_taken = self.balance_changes.sum(:amount).abs
      if funds_taken > self.amount
        puts 'overpaid, review'
        return false
      end

      unless self.check_address
        puts 'invalid address, destroying'
        self.cancel
        return false
      end

      unless user.balances.where('amount < 0').empty?
        puts 'negative balances'
        return false
      end

      unless funds_taken >= self.amount || balance.take_funds(self.amount, self)
        puts 'bad balance'
        self.cancel
        return false
      end

      return true if self.txid

      unless self.valid?
        puts self.errors.messages.inspect
        puts 'invalid. destroying'
        self.cancel
        return false
      end

      acc = "user-#{self.user_id}"
      amt = (self.amount.to_f / 10 ** 8) - (self.currency.tx_fee || 0).to_f

      begin
        txs = self.currency.rpc.listtransactions(acc, batch, skip)
        raise 'no txs' unless txs
      rescue => e
        puts 'unable to connect wallet'
        return false
      end

      txs.select {|tx| tx['category'] == 'send'}.reverse.each do |tx|
        next if Withdrawal.find_by_txid(tx['txid'])
        puts "#{tx['amount'].abs} | #{amt}"
        next unless tx['amount'].abs == amt || (tx['amount'].abs - amt).abs < 0.001
        self.failed = false
        self.processed = true
        self.txid = tx['txid']
        puts "txid=#{self.txid}"
        self.save(validate: false)
        return true
      end

      if !txs || txs.count < 50
        puts "invalid, retry"
        self.process
      else
        self.verify(skip+batch, batch)
      end
    end
  end

  def check_amounts
    return if send_amount >= 0.01
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

  def cancel
    return false if cancelled
    self.update_attribute :cancelled, true
    self.balance.add_funds(self.amount, self, 'cancelled withdrawal')
    self.user.notifications.create(
      title: "#{self.currency.name} self failed",
      body: "#{n2f self.amount} #{self.currency.name} credited back to your account"
    )
  end

  def send_amount
    (self.amount.to_f / 10 ** 8) - (currency.tx_fee || 0).to_f
  end

  def process
    self.with_lock do
      self.reload
      return if self.processed
      return unless self.valid?
      begin
        funds_taken = (self.balance_changes.sum(:amount).abs == self.amount)
        raise 'failed to take funds' unless funds_taken || balance.take_funds(self.amount, self)
        account = balance.rpc_account
        move_amount = (self.amount + (self.amount / 100)).to_f / 10 ** 8
        amount  = send_amount
        move    = currency.rpc.move '', account, move_amount
        raise 'unable to move funds' unless move
        txid    = currency.rpc.sendfrom account, self.address, amount
        raise 'sendfrom failed' unless txid
        self.failed = false
        self.processed = true
        self.txid = txid
        self.user.notifications.create(
          title: "#{currency.name} withdrawal processed",
          body: "#{n2f self.amount} #{currency.name} sent to #{self.address}"
        )
      rescue => e
        case e.message
        when 'Invalid amount', 'Transaction too large'
          puts e.message
          self.cancel
        else
          self.failed = true
          puts e.inspect
          puts e.backtrace
        end
      ensure
        return unless self.persisted?
        self.save(validate: false)
        return unless self.balance_change
        self.balance_change.touch
        self.balance_change.pusher_update
      end
    end

  end
end
