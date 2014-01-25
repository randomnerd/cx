Cx.TradePairController = Ember.Controller.extend
  needs: ['trades', 'orders']
  askRate: 0
  bidRate: 0
  askTotal: 0
  bidTotal: 0
  askAmount: 0
  bidAmount: 0

Cx.TradePairsController = Ember.ArrayController.extend
  sortProperties: ['url_slug']
  setupPusher: (->
    h.setupPusher @store, 'tradePair', 'tradePairs'
  ).on('init')
  btc: (->
    @filter (o) -> o.get('market.name') == 'BTC'
  ).property('@each')
  ltc: (->
    @filter (o) -> o.get('market.name') == 'LTC'
  ).property('@each')
  doge: (->
    @filter (o) -> o.get('market.name') == 'DOGE'
  ).property('@each')

