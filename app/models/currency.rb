class Currency < ActiveRecord::Base
  include ApplicationHelper
  has_many :incomes
  has_many :withdrawals
  has_many :deposits
  has_many :blocks
  has_many :worker_stats
  has_many :hashrates
  scope :by_name, -> name { where(name: name) }

  include PusherSync
  def pusher_channel
    "currencies"
  end

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
    return if txs.try(:count) == 0

    txs.reverse.each do |tx|
      next unless tx['category'] == 'receive'
      return if tx['category'] == 'move' && tx['account'] == 'stop_processing_here'
      return if Deposit.find_by_txid(tx['txid'])
      rtx = self.rpc.gettransaction(tx['txid'])
      rtx['details'].each do |txin|
        next unless txin['category'] == 'receive'
        wallet = Wallet.find_by_address(txin['address'])
        next unless wallet

        deposit = wallet.deposits.create({
          user_id: wallet.user_id,
          currency_id: wallet.currency_id,
          amount: txin['amount'] * 10 ** 8,
          txid: tx['txid'],
          confirmations: tx['confirmations']
        })

        wallet.user.notifications.create({
          title: "New #{self.name} deposit",
          body: "Incoming transaction for #{txin['amount']} #{self.name}"
        })
        self.add_deposit(deposit)

      end
    end

    self.process_deposits(skip + batch, batch)
  end

  def process_withdrawals
    withdrawals.unprocessed.each do |withdrawal|
      begin
        balance = withdrawal.balance
        account = balance.rpc_account
        amount  = (withdrawal.amount / 10 ** 8) - self.tx_fee
        move    = self.rpc.move '', account, amount
        raise 'unable to move funds' unless move
        txid    = self.rpc.sendfrom account, withdrawal.address, amount
        raise 'sendfrom failed' unless txid
        withdrawal.processed = true
        withdrawal.txid = txid
        withdrawal.user.notifications.create(
          title: "#{self.name} withdrawal processed",
          body: "#{n2f withdrawal.amount} #{self.name} sent to #{withdrawal.address}"
        )
      rescue => e
        balance.add_funds(withdrawal.amount, withdrawal)
        withdrawal.failed = true
        puts e.inspect
        puts e.backtrace
        withdrawal.user.notifications.create(
          title: "#{self.name} withdrawal failed",
          body: "#{n2f withdrawal.amount} #{self.name} were credited back to your account"
        )
      ensure
        withdrawal.save
        withdrawal.balance_change.touch
        withdrawal.balance_change.pusher_update
      end
    end
  end

  def process_transactions
    update_deposit_confirmations
    process_withdrawals
    process_deposits
  end

  def update_deposit_confirmations
    deposits = self.deposits.unprocessed.where('confirmations < ?', self.tx_conf)
    deposits.each do |deposit|
      begin
        update = self.rpc.gettransaction deposit.txid
        next unless update
        return if update['confirmations'] == deposit.confirmations

        deposit.update_attribute :confirmations, update['confirmations']
        self.add_deposit(deposit)
      rescue => e
        puts e.inspect
        puts e.backtrace
        next
      end
    end
  end

  def process_mining
    update_diff_and_hashrate
    update_user_hashrates
    update_blocks
    process_payouts
  end

  def update_diff_and_hashrate
    hrate = self.rpc.getnetworkhashps
    data = self.rpc.getdifficulty
    diff = data.try(:[], 'proof-of-work')
    diff ||= data
    self.diff = diff if diff
    self.net_hashrate = hrate if hrate
    self.save
  end

  def update_user_hashrates
    users = {}
    self.worker_stats.active.each do |hr|
      users[hr.worker.user_id] ||= 0
      users[hr.worker.user_id]  += hr.hashrate
    end
    users.each do |user_id, rate|
      Hashrate.set_rate(self.id, user_id, rate)
    end
  end

  def update_blocks
    self.blocks.immature.each do |block|
      info = self.rpc.gettransaction(block.txid)
      next unless info
      block.category = info['details'][0]['category']
      block.confirmations = info['confirmations']
      block.save
    end
  end

  def process_payouts
    self.blocks.generate.unpaid.each do |block|
      block.process_payouts
    end
  end
end
