class Block < ActiveRecord::Base
  belongs_to :currency
  belongs_to :user
  has_many :block_payouts

  scope :immature, -> { where(category: 'immature') }
  scope :generate, -> { where(category: 'generate') }
  scope :unpaid,   -> { where(paid: false) }
  scope :by_currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }
  scope :recent, -> { limit(20).order('created_at desc') }

  include ApplicationHelper
  include PusherSync
  def pusher_channel
    "blocks-#{self.currency_id}"
  end

  def pusher_update
    return unless self.class.recent.include? self
    PusherMsg.perform_async(pusher_channel, "u", pusher_serialize)
  end

  def process_payouts
    return unless self.category == 'generate'
    return if self.paid

    fees = 0
    self.block_payouts.unpaid.each do |payout|
      balance = payout.user.balance_for(self.currency_id)
      fees   += payout.fee
      next unless balance.add_funds(payout.reward_minus_fee, payout)
      payout.user.notifications.create({
        title: 'Mining reward',
        body: "#{n2f payout.reward_minus_fee} #{currency.name} added to your balance"
      })
      payout.update_attribute :paid, true
    end

    self.currency.incomes.create(amount: fees, subject: self) if fees > 0
    unpaid = self.block_payouts.unpaid.count
    self.update_attribute(:paid, true) if unpaid == 0
  end
end
