class Api::V2::TradePairsController < Api::V2::BaseController
  has_scope :url_slug, as: :urlSlug
end
