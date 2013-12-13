class Api::V2::DepositsController < Api::V2::BaseController
  before_filter :authenticate_user!
  has_scope :by_currency_name, as: :currency_name

  def collection
    end_of_association_chain.unprocessed
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
