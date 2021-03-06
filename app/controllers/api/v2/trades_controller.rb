class Api::V2::TradesController < Api::V2::BaseController
  belongs_to :trade_pair, param: :tradePair
  has_scope :user

  protected
  def collection
    @collection ||= end_of_association_chain.limit(50).order('created_at desc')
  end
end
