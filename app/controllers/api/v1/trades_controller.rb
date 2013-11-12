class Api::V1::TradesController < Api::V1::BaseController
  belongs_to :trade_pair, param: :tradePair
  has_scope :user

  protected
  def collection
    @trades ||= end_of_association_chain.limit(50).order('created_at desc')
  end
end
