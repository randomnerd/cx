class TradePairSerializer < ActiveModel::Serializer
  attributes :id, :buy_fee, :sell_fee, :last_price, :currency_id, :market_id,
             :public, :url_slug, :rate_min, :rate_max, :currency_volume,
             :market_volume, :updated_at
end
