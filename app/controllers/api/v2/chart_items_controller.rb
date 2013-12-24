class Api::V2::ChartItemsController < Api::V2::BaseController
  belongs_to :trade_pair

  def index
    render json: Oj.dump(ChartItem.lighting(params[:trade_pair_id]), mode: :compat)
  end
end
