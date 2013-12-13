class Api::V2::BlockPayoutsController < Api::V2::BaseController
  before_filter :authenticate_user!, only: [:index]
  has_scope :by_currency_name, as: :currency_name

  def index
    respond_with end_of_association_chain.recent
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
