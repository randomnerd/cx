class Block < ActiveRecord::Base
  belongs_to :currency
  belongs_to :user
  has_many :block_payouts

  scope :immature, -> { where(category: 'immature') }
  scope :generate, -> { where(category: 'generate') }
  scope :orphan,   -> { where(category: 'orphan') }
  scope :unpaid,   -> { where(paid: false) }
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
  scope :recent, -> { limit(20).order('created_at desc') }
  scope :with_payouts, -> { joins(:block_payouts) }
  scope :non_switchpool, -> { where(switchpool: false) }

  include ApplicationHelper
  include PusherSync
  def pusher_channel
    if switchpool
      sw = Currency.find_by_name("SwitchPool-#{algo}")
      "blocks-#{sw.id}"
    else
      "blocks-#{self.currency_id}"
    end
  end

  def pusher_update
    return unless currency.blocks.recent.include? self
    super
  end

  def process_payouts
    self.with_lock do
      self.reload
      return unless self.category == 'generate'
      return if self.paid

      fees = 0
      self.block_payouts.unpaid.each do |payout|
        balance = payout.user.balance_for(self.currency_id)
        fees   += payout.fee
        unless payout.reward_minus_fee > 0
          payout.destroy
          next
        end
        next unless balance.add_funds(payout.reward_minus_fee, payout)
        # payout.user.notifications.create({
        #   title: 'Mining reward',
        #   body: "#{n2f payout.reward_minus_fee} #{currency.name} added to your balance"
        # })
        payout.update_attribute :paid, true
      end

      self.currency.incomes.create(amount: fees, subject: self) if fees > 0
      unpaid = self.block_payouts.unpaid.count
      self.update_attribute(:paid, true) if unpaid == 0
    end
  end

  def update_confirmations
    info = currency.rpc.gettransaction(self.txid)
    return unless info.try(:[], 'details').try(:[], 0)
    self.category = info['details'][0]['category']
    self.confirmations = info['confirmations']
    save
  rescue => e
    puts e.inspect
  end

  def self.json_fields
    [:id, :created_at, :updated_at, :currency_id, :number, :category,
             :reward, :finder, :confirmations, :switchpool]
  end

  def as_json(options = {})
    super(options.merge(only: self.class.json_fields))
  end
end
