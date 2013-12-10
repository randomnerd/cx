class Api::V1::BlockPayoutsController < Api::V1::BaseController
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
