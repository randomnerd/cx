Cx.TradePairController = Ember.Controller.extend
  needs: ['trades', 'orders']

Cx.TradePairsController = Ember.ArrayController.extend
  sortProperties: ['url_slug']
  setupPusher: (->
    h.setupPusher @store, 'tradePair', 'tradePairs'
  ).on('init')
  btc: (->
    @filter (o) -> o.get('market.name') == 'BTC' && o.get('public')
  ).property('@each')
  ltc: (->
    @filter (o) -> o.get('market.name') == 'LTC' && o.get('public')
  ).property('@each')
