class Api::V1::WorkerStatsController < Api::V1::BaseController
  before_filter :authenticate_user!
  has_scope :currency_name

  def index
    respond_with end_of_association_chain.active
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
