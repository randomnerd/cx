class Api::V1::BalancesController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:index]
  has_scope :currency

  protected
  def begin_of_association_chain
    current_user
  end
end
