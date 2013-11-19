Cx.TradesController = Em.ArrayController.extend
  sortProperties: ['created_at']
  sortAscending: false
  needs: ['auth']
  tradePairId: null
  setupPusher: (->
    return unless tpId = @get 'tradePairId'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'trade', "trades-#{tpId}"
  ).on('init').observes('tradePairId')

  own: (->
    return unless tpId = @get 'tradePairId'
    @ownProxy = undefined if @ownProxy
    @store.find 'trade',
      tradePair: tpId
      user: @get 'controllers.auth.id'
    trades = @filter (o) =>
      (o.get('ask_user_id') == parseInt(@get 'controllers.auth.id') ||
      o.get('bid_user_id') == parseInt(@get 'controllers.auth.id')) &&
      o.get('trade_pair_id') == @get 'tradePairId'
    @ownProxy = h.sortedArray(trades, @sortProperties, @sortAscending)
  ).property('controllers.auth.id', 'tradePairId', '@each')


