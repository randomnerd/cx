class Api::V2::TradePairsController < Api::V2::BaseController
  skip_before_filter :authenticate_user!
  has_scope :url_slug, as: :urlSlug

  def collection
    end_of_association_chain.public
  end
end
