Cx.TradePairController = Ember.Controller.extend
  needs: ['trades', 'orders']

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
