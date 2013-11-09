class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :trade_pair

  scope :recent, -> { order('created_at desc').limit(50) }
  scope :active, -> { where(complete: false).where(cancelled: false) }

  def trades
    if bid
      Trade.where(bid_id: id)
    else
      Trade.where(ask_id: id)
    end
  end
end
