class Api::V2::ChartItemsController < Api::V2::BaseController
  belongs_to :trade_pair

  def index
    rel = ChartItem.where(trade_pair_id: params[:trade_pair_id])
    if stale?(rel)
      puts 'stale'
      render json: FastJson.raw_dump(rel)
    end
  end
end
