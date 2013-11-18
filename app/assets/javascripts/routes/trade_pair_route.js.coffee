Cx.TradePairRoute = Ember.Route.extend
  model: (params) ->
    tps = @store.filter 'tradePair', (tp) ->
      tp.get('url_slug') == params.url_slug
    tps.get('firstObject')

  setupController: (c, pair) ->
    c.set 'model', pair
    orders = @store.find('order', {tradePair: pair.get('id')})
    trades = @store.find('trade', {tradePair: pair.get('id')})
    @controllerFor('trades').set 'tradePairId', parseInt(pair.get('id'))
    @controllerFor('orders').set 'tradePairId', parseInt(pair.get('id'))
    @controllerFor('trades').set 'model', trades
    @controllerFor('orders').set 'model', orders

  deactivate: ->
    @ordersChannel?.unsubscribe()
    @ordersChannel = undefined
