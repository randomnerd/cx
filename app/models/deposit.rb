class Deposit < ActiveRecord::Base
  belongs_to :user
  belongs_to :wallet
  belongs_to :currency
  has_one :balance_change, as: :subject

  scope :unprocessed, -> { where(processed: false) }
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }

  validate :check_duplicates, on: :create

  def self.lookup_list(curr, txids)
    txids.each { |txid| self.lookup(curr, txid) }
  end

  def self.lookup(curr, txid)
    case curr.class.name
    when 'String'
      currency = Currency.find_by_name(curr)
    when 'Fixnum'
      currency = Currency.find(curr)
    when 'Currency'
      currency = curr
    end

    return true if Deposit.find_by_txid(txid)
    tx = currency.rpc.gettransaction txid
    puts tx.inspect
    rtx = currency.rpc.gettransaction(tx['txid'])
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
        title: "New #{currency.name} deposit",
        body: "Incoming transaction for #{txin['amount']} #{currency.name}"
      })
      currency.add_deposit(deposit)

    end

  end

  def check_duplicates
    return unless user.deposits.find_by_txid(self.txid)
    errors.add(:txid, 'Duplicate deposit!')
  end

  include PusherSync
  def pusher_channel
    "private-deposits-#{self.user_id}"
  end

  def update_confirmations
    update = currency.rpc.gettransaction txid
    return unless update
    return if update['confirmations'] == confirmations

    update_attribute :confirmations, update['confirmations']
    currency.add_deposit(self)
  rescue => e
    puts e.inspect
    puts e.backtrace
  end
end
