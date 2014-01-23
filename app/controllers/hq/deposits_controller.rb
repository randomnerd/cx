class Hq::DepositsController < Hq::BaseController
  def index
  end

  def lookup
    if params[:currency] && params[:txid]
      @result = Deposit.lookup params[:currency], params[:txid]
    end
  end
end
