class BlockPayout < ActiveRecord::Base
  belongs_to :block
  belongs_to :user
  has_one :currency, through: :block

  scope :unpaid, -> { where(paid: false) }
  scope :by_currency_name, -> name {
    currency = Currency.find_by_name(name)
    includes(:block).where(blocks: {currency_id: currency.id})
  }

  scope :recent, -> { limit(20).order('block_payouts.created_at desc') }

  def fee
    return 0 if user.no_fees
    (self.reward / 100 * self.block.currency.mining_fee).to_i
  end

  def reward
    (self.block.reward * self.amount).to_i
  end

  def reward_minus_fee
    self.reward - self.fee
  end
end
