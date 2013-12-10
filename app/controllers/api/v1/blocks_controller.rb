class Api::V1::BlocksController < Api::V1::BaseController
  has_scope :by_currency_name, as: :currency_name

  def index
    respond_with end_of_association_chain.recent
  end
end
