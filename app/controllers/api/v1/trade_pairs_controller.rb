class Api::V1::TradePairsController < Api::V1::BaseController
  has_scope :url_slug, as: :urlSlug
end
