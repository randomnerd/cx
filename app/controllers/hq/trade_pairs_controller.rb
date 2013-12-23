class Hq::TradePairsController < Hq::BaseController
  def index
    @trade_pairs = collection.order(:url_slug)
  end

  def disable
    resource.update_attributes public: false
    redirect_to :back
  end

  def enable
    resource.update_attributes public: true
    redirect_to :back
  end
end
