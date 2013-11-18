class Api::V1::BalanceChangesController < Api::V1::BaseController
  before_filter :authenticate_user!
  has_scope :by_currency_name, as: :currency_name

  def collection
    end_of_association_chain.changes_total
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
