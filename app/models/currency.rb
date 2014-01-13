class Currency < ActiveRecord::Base
  include ApplicationHelper
  has_many :incomes
  has_many :withdrawals
  has_many :deposits
  has_many :blocks
  has_many :worker_stats
  has_many :hashrates
  has_many :balances
  scope :with_mining, -> { where(mining_enabled: true) }
  scope :by_name, -> name { where(name: name) }
  scope :public, -> { where(public: true) }

  include PusherSync
  def pusher_channel
    "currencies"
  end

  def avg_btc_rate
    return 1 if name == 'BTC'
    tp = TradePair.where(currency: self, market: Currency.find_by_name('BTC')).first
    tp.try(:avg_bid_rate) || 0
  end

  def avg_ltc_rate
    tp = TradePair.where(currency: self, market: Currency.find_by_name('LTC')).first
    tp.try(:avg_bid_rate, 5) || 0
  end

  def avg_block_reward
    return 25 * 10**8 if name == 'BTC'
    return 50 * 10**8 if name == 'LTC'
    arr = blocks.limit(10).order('created_at desc').pluck(:reward)
    return 0 if arr.empty?
    arr.sum / arr.size
  end

  def mining_score_base
    return (50 / diff * avg_btc_rate * 10**8) if name == 'LTC'
    return (25 / diff * 10**8) if name == 'BTC'
    case algo
    when 'scrypt'
      Currency.find_by_name('LTC').mining_score_base
    else
      Currency.find_by_name('BTC').mining_score_base
    end
  end

  def calc_mining_score
    return 0 unless mining_enabled && diff
    return 0 if avg_btc_rate == 0
    score = avg_block_reward / diff * avg_btc_rate
    score = (score / mining_score_base).round(2)
    update_attribute :mining_score, score
    return score
  end

  def trade_pairs
    TradePair.where('currency_id = ? or market_id = ?', self.id, self.id)
  end

  def balance_diff
    actual = self.balances.sum('amount+held').to_f/10**8
    real   = self.rpc.getbalance.to_f
    case self.name
    when 'WDC' then real += 40000
    when 'BTC' then real += 180
    when 'LTC' then real += 1500
    end
    real - actual
  rescue => e
    nil
  end

  def balance_sum
    actual  = self.balances.where('amount >= 0').sum('amount+held').to_f/10**8
    actual += self.balances.where('amount < 0').sum('held').to_f/10**8
    actual.round(8)
  end

  def client_version
    self.rpc.getinfo.try(:[], 'version')
  rescue => e
    'n/a'
  end

  def balance_sum_neg
    self.balances.where('amount < 0').sum('amount').to_f/10**8
  end

  def balance_diff_neg
    real     = self.rpc.getbalance.to_f
    deposits = self.deposits.unprocessed.sum(:amount).to_f/10**8
    case self.name
    when 'WDC' then real += 40000
    when 'BTC' then real += 180
    when 'LTC' then real += 1500
    end
    (real - deposits - balance_sum).round(8)
  rescue => e
    0
  end

  def get_balance
    rpc.getbalance
  rescue => e
    0
  end

  def rpc
    @rpc ||= CryptoRPC.new(self)
  end

  def add_deposit(deposit)
    deposit.with_lock do
      deposit.reload
      return if deposit.processed
      return unless deposit.confirmations >= self.tx_conf
      balance = deposit.user.balance_for(self.id)
      return unless balance.add_funds(deposit.amount, deposit)
      deposit.update_attribute :processed, true
      deposit.user.notifications.create({
        title: "#{self.name} deposit confirmed",
        body: "#{n2f deposit.amount} #{self.name} added to your balance"
      })
    end
  end

  def process_deposits(skip = 0, batch = 50)
    txs = rpc.listtransactions('*', batch, skip)
    return unless txs
    return if txs.try(:count) == 0

    txs.reverse.each do |tx|
      return if tx['category'] == 'move' && tx['account'] == 'stop_processing_here'
      next unless tx['category'] == 'receive'
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
        next unless deposit.persisted?

        wallet.user.notifications.create({
          title: "New #{self.name} deposit",
          body: "Incoming transaction for #{txin['amount']} #{self.name}"
        })
        self.add_deposit(deposit)

      end
    end

    self.process_deposits(skip + batch, batch)
  end

  def process_transactions
    update_deposit_confirmations
    process_deposits
  end

  def update_deposit_confirmations
    deposits = self.deposits.unprocessed.where('confirmations < ?', self.tx_conf)
    deposits.each &:update_confirmations
  end

  def process_mining
    update_diff_and_hashrate
    calc_mining_score
    update_user_hashrates
    update_blocks
    process_payouts
  end

  def update_diff_and_hashrate
    begin
      hrate = self.rpc.getnetworkhashps
    rescue => e
    end
    data = self.rpc.getdifficulty
    diff = data.try(:[], 'proof-of-work')
    diff ||= data
    self.diff = diff if diff
    self.net_hashrate = hrate / 1000 if hrate
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
    self.blocks.orphan.each do |block|
      block.block_payouts.each &:delete
    end
  end

  def process_payouts
    self.blocks.generate.unpaid.each do |block|
      block.process_payouts
    end
  end

  def self.json_fields
    [:id, :name, :desc, :tx_fee, :tx_conf, :blk_conf, :hashrate,
             :net_hashrate, :last_block_at, :mining_enabled, :mining_url,
             :mining_fee, :donations, :algo, :diff, :updated_at,
             :mining_score]
  end
end
