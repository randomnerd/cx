Cx.TradePairController = Ember.Controller.extend
  needs: ['trades', 'orders']

Cx.TradePairsController = Ember.ArrayController.extend
  sortProperties: ['url_slug']
  setupPusher: (->
    h.setupPusher @store, 'tradePair', 'tradePairs'
  ).on('init')
  btc: (->
    @get('public').filter (o) -> o.get('market.name') == 'BTC'
  ).property('public.@each')
  ltc: (->
    @get('public').filter (o) -> o.get('market.name') == 'LTC'
  ).property('public.@each')

  public: (->
    @filter (o) -> o.get('public')
  ).property('@each', '@each.public')
