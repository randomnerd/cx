class TradePairSerializer < ActiveModel::Serializer
  attributes :id, :buy_fee, :sell_fee, :last_price, :currency_id, :market_id,
             :public, :url_slug
end
