class Api::V2::BalanceChangesController < Api::V2::BaseController
  before_filter :authenticate_user!
  has_scope :by_currency_name, as: :currency_name

  def collection
    page = params[:page].try(:to_i) || 1
    per_page = 100
    offset = (page - 1) * per_page
    chain = end_of_association_chain.changes_total.order('balance_changes.created_at desc')
    chain.limit(per_page).offset(offset).includes(balance: [:currency])
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
