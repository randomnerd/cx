Cx.TradePair = DS.Model.extend
  buyFee: DS.attr('number')
  sellFee: DS.attr('number')
  last_price: DS.attr('number')
  currency: DS.belongsTo('currency')
  market: DS.belongsTo('currency')
  public: DS.attr('boolean')
  url_slug: DS.attr('string')
  currency_volume: DS.attr('number')
  market_volume: DS.attr('number')
  rate_min: DS.attr('number')
  rate_max: DS.attr('number')
  name: (->
    "#{@get 'currency.name'} / #{@get 'market.name'}"
  ).property('currency.name', 'market.name')
  trades: DS.hasMany('trade')
  shortCurrVolume: (->
    h.n2f(@get('currency_volume')).toFixed(2)
  ).property('currency_volume')
  shortMktVolume: (->
    h.n2f(@get('market_volume')).toFixed(2)
  ).property('market_volume')

Cx.TradePair.FIXTURES = [
  {
    id: 1
    buyFee: 0.2
    sellFee: 0.2
    lastPrice: 0.0122
    currency: 2
    market: 1
    public: true
    urlSlug: 'ltc_btc'
  }
  {
    id: 2
    buyFee: 0.2
    sellFee: 0.2
    lastPrice: 0.0122
    currency: 3
    market: 1
    public: true
    urlSlug: 'wdc_btc'
  }

]
