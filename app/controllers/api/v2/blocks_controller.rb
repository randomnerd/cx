class Api::V2::BlocksController < Api::V2::BaseController

  def index
    curr = Currency.find_by_name(params[:currency_name])
    if curr.name.match /switchpool/i
      respond_with Block.where(algo: curr.algo, switchpool: true).recent
    else
      respond_with curr.blocks.non_switchpool.recent
    end
  end
end
