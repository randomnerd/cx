class Api::V1::HashratesController < Api::V1::BaseController
  has_scope :currency_name

  def index
    respond_with end_of_association_chain.active
  end
end
