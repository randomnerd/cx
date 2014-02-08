class Api::V2::BlocksController < Api::V2::BaseController

  def collection
    return @collection if @collection
    curr = Currency.find_by_name(params[:currency_name])
    if curr.name.match /switchpool/i
      @collection ||= Block.where(algo: curr.algo, switchpool: true).recent
    else
      @collection ||= curr.blocks.non_switchpool.recent
    end
  end
end
