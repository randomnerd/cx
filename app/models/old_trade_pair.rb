class OldTradePair
  include Mongoid::Document
  store_in collection: "trade_pairs"

  field :public, type: Boolean
  field :buyFee, type: Float
  field :sellFee, type: Float
  field :currId, type: String
  field :marketId, type: String
  field :lastprice, type: Integer
  field :urlSlug, type: String
  field :min, type: Float
  field :max, type: Float
  field :volume, type: Hash

  def self.migrate
    OldTradePair.all.each do |tp|
      TradePair.create({
        buy_fee: tp.buyFee,
        sell_fee: tp.sellFee,
        currency: Currency.find_by_old_id(tp.currId),
        market: Currency.find_by_old_id(tp.marketId),
        public: tp.public,
        url_slug: tp.urlSlug,
        last_price: tp.lastprice,
        old_id: tp._id,
        currency_volume: tp.volume['currency'] * 10 ** 8,
        market_volume: tp.volume['market'] * 10 ** 8,
        rate_min: tp.min * 10 ** 8,
        rate_max: tp.max * 10 ** 8
      })
    end
  end
end
