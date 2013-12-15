Cx.OrdersController = Em.ArrayController.extend
  needs: ['auth']
  tradePairId: null
  setupPusher: (->
    return unless tpId = @get 'tradePairId'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'order', "orders-#{tpId}"
  ).on('init').observes('tradePairId')

  own: (->
    return unless @get 'tradePairId'
    @filter (o) =>
      ret = o.get('user_id') == parseInt(@get 'controllers.auth.id') &&
      o.get('trade_pair_id') == @get('tradePairId') &&
      o.get('cancelled') == false &&
      o.get('complete') == false
      ret
  ).property('controllers.auth.id', 'tradePairId', '@each')

  ask: (->
    return unless @get 'tradePairId'
    @filter (o) =>
      o.get('trade_pair_id') == @get('tradePairId') &&
      o.get('cancelled') == false &&
      o.get('complete') == false &&
      o.get('bid') == false
  ).property('tradePairId', '@each')

  bid: (->
    return unless @get 'tradePairId'
    @filter (o) =>
      o.get('trade_pair_id') == @get('tradePairId') &&
      o.get('cancelled') == false &&
      o.get('complete') == false &&
      o.get('bid') == true
  ).property('tradePairId', '@each')
