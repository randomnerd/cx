class Hq::TradePairsController < Hq::BaseController
  def index
    @trade_pairs = collection.order(:url_slug)
  end

  def disable
    resource.update_attributes public: false
    redirect_to :back, notice: "Trade Pair ##{resource.id} (#{resource.currency.name}/#{resource.market.name}) has been disabled"
  end

  def enable
    resource.update_attributes public: true
    redirect_to :back, notice: "Trade Pair ##{resource.id} (#{resource.currency.name}/#{resource.market.name}) has been enabled"
  end
end
