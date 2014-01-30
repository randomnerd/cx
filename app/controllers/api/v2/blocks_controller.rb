class Api::V2::BlocksController < Api::V2::BaseController

  def collection
    curr = Currency.find_by_name(params[:currency_name])
    if curr.name.match /switchpool/i
      return Block.where(algo: curr.algo, switchpool: true).recent
    else
      return curr.blocks.non_switchpool.recent
    end
  end
end
