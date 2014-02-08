class Api::V2::BlockPayoutsController < Api::V2::BaseController
  before_filter :authenticate_user!, only: [:index]
  has_scope :by_currency_name, as: :currency_name

  def collection
    return @collection if @collection
    curr = Currency.find_by_name(params[:currency_name])
    if curr.name.match /switchpool/i
      blocks = Block.where(algo: curr.algo, switchpool: true).recent.pluck(:id)
      @collection ||= current_user.block_payouts.where(block_id: blocks)
    else
      @collection ||= end_of_association_chain.recent.includes(:block).where(blocks: {switchpool: false})
    end
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
