class Currency < ActiveRecord::Base
  include ApplicationHelper
  has_many :incomes

  def rpc
    @rpc ||= CryptoRPC.new(self)
  end

  def add_deposit(deposit)
    return unless deposit.confirmations >= self.tx_conf
    balance = deposit.user.balance_for(self.id)
    return unless balance.add_funds(deposit.amount, deposit)
    deposit.update_attribute :processed, true
    deposit.user.notifications.create({
      title: "#{self.name} deposit confirmed",
      body: "#{n2f deposit.amount} #{self.name} added to your balance"
    })
  end

  def process_deposits(skip = 0, batch = 50)
    txs = rpc.listtransactions('*', batch, skip)
    return unless txs
    # return if txs.try(:[], 'error')
    return if txs.try(:count) == 0

    txs.reverse.each do |tx|
      next unless tx['category'] == 'receive'
      return if Deposit.find_by_txid(tx['txid'])

      wallet = Wallet.find_by_address(tx['address'])
      next unless wallet

      deposit = wallet.deposits.create({
        user_id: wallet.user_id,
        currency_id: wallet.currency_id,
        amount: tx['amount'] * 10 ** 8,
        txid: tx['txid'],
        confirmations: tx['confirmations']
      })

      wallet.user.notifications.create({
        title: "New #{self.name} deposit",
        body: "Incoming transaction for #{tx['amount']} #{self.name}"
      })
      self.add_deposit(deposit)
    end

    self.process_deposits(skip + batch, batch)
  end

  def process_withdrawals
    Withdrawal.unprocessed.each do |withdrawal|
      begin
        account = withdrawal.balance.rpc_account
        amount  = withdrawal.amount / 10 ** 8
        move    = self.rpc.move '', account, amount
        raise 'unable to move funds' unless move
        txid    = self.rpc.sendfrom withdrawal.balance.rpc_account, amount
        raise 'sendfrom failed' unless txid
        withdrawal.processed = true
        added   = withdrawal.balance.add_funds(withdrwal.amount, withdrawal)
        raise 'add_funds failed' unless added
        withdrawal.txid = txid
      rescue
        withdrawal.failed = true
      ensure
        withdrawal.save
      end
    end
  end

  def process_transactions
    update_deposit_confirmations
    process_withdrawals
    process_deposits
  end

  def update_deposit_confirmations
    deposits = Deposit.unprocessed.where('confirmations < ?', self.tx_conf)
    deposits.each do |deposit|
      begin
        update = self.rpc.gettransaction deposit.txid
        next unless update
        deposit.update_attribute :confirmations, update['confirmations']
        self.add_deposit(deposit)
      rescue => e
        puts e.inspect
        puts e.backtrace
        next
      end
    end
  end
end
