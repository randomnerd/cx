class Api::V2::HashratesController < Api::V2::BaseController
  has_scope :currency_name

  def index
    render json: collection
  end

  def collection
    end_of_association_chain.active
  end
end
