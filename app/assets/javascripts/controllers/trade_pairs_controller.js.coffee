Cx.TradePairController = Ember.Controller.extend
  needs: ['trades', 'orders']

Cx.TradePairsController = Ember.ArrayController.extend
  sortProperties: ['url_slug']
  setupPusher: (->
    h.setupPusher @store, 'tradePair', 'tradepairs'
  ).on('init')
