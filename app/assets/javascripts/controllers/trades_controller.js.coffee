Cx.TradesController = Em.ArrayController.extend
  needs: ['auth']
  tradePairId: null
  setupPusher: (->
    return unless tpId = @get 'tradePairId'
    h.setupPusher @store, 'trade', "trades-#{tpId}"
  ).on('init').observes('tradePair')

  filterByPair: (->
    trades = @store.filter 'trade', (o) =>
      o.get('trade_pair_id') == @get 'tradePairId'
    @set 'model', trades
  ).observes('tradePairId')

  own: (->
    @store.find 'trade',
      tradePair: @get 'tradePairId'
      user: @get 'controllers.auth.id'
    @store.filter 'trade', (o) =>
      (o.get('ask_user_id') == parseInt(@get 'controllers.auth.id') ||
      o.get('bid_user_id') == parseInt(@get 'controllers.auth.id')) &&
      o.get('trade_pair_id') == @get 'tradePairId'
  ).property('controllers.auth.id', 'tradePairId')


