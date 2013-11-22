Cx.TradePairRoute = Ember.Route.extend
  model: (params) ->
    tps = @store.filter 'tradePair', (tp) ->
      tp.get('url_slug') == params.url_slug
    tps.get('firstObject')

  setupController: (c, pair) ->
    c.set 'model', pair
    @controllerFor('orders').set 'model', []
    @controllerFor('trades').set 'model', []

    @store.find('order', {tradePair: pair.get('id')}).then (d) =>
      @controllerFor('orders').set 'model', @store.filter 'order', (o) ->
        o.get('trade_pair_id') == parseInt(pair.get 'id')
      @controllerFor('orders').set 'tradePairId', parseInt(pair.get('id'))

    @store.find('trade', {tradePair: pair.get('id')}).then (d) =>
      @controllerFor('trades').set 'model', @store.filter 'trade', (o) ->
        o.get('trade_pair_id') == parseInt(pair.get 'id')
      @controllerFor('trades').set 'tradePairId', parseInt(pair.get('id'))

  deactivate: ->
    @ordersChannel?.unsubscribe()
    @ordersChannel = undefined
