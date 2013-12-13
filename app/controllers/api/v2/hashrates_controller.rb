class Api::V2::HashratesController < Api::V2::BaseController
  has_scope :currency_name

  def index
    respond_with end_of_association_chain.active
  end
end
