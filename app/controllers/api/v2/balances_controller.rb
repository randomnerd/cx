class Api::V2::BalancesController < Api::V2::BaseController
  before_filter :authenticate_user!, only: [:index]
  has_scope :currency

  protected
  def begin_of_association_chain
    current_user
  end
end
