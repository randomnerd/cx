class Api::V2::BalancesController < Api::V2::BaseController
  before_filter :authenticate_user!, only: [:index]
  has_scope :currency

  def index
    render json: collection
  end

  protected
  def begin_of_association_chain
    current_user
  end

  def collection
    @collection ||= end_of_association_chain.includes(:currency)
  end
end
