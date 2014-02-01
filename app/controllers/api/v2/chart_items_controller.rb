class Api::V2::ChartItemsController < Api::V2::BaseController
  belongs_to :trade_pair

  def index
    rel = ChartItem.where(trade_pair_id: params[:trade_pair_id])
    if stale? last_modified: rel.last.updated_at.utc, etag: rel.last
      render json: FastJson.raw_dump(rel)
    end
  end
end
