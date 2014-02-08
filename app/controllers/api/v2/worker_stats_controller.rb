class Api::V2::WorkerStatsController < Api::V2::BaseController
  before_filter :authenticate_user!
  has_scope :currency_name

  def index
    render json: collection
  end

  def collection
    @collection ||= end_of_association_chain.active
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
