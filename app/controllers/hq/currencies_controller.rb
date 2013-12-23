class Hq::CurrenciesController < Hq::BaseController
  def index
    @currencies = collection.order(:name)
  end

  def disable
    resource.update_attributes public: false, mining_enabled: false
    resource.trade_pairs.each {|tp| tp.update_attributes public: false }
    redirect_to :back
  end

  def enable
    resource.update_attributes public: true, mining_enabled: true
    resource.trade_pairs.each {|tp| tp.update_attributes public: true }
    redirect_to :back
  end
end
