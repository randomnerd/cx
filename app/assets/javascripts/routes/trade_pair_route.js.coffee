Cx.TradeIndexRoute = Ember.Route.extend
  model: -> @store.findAll('tradePair')
  setupController: (c, pairs) -> c.set 'model', pairs
  actions:
    openPair: (pair) ->
      @router.transitionTo 'tradePair', pair

Cx.TradePairRoute = Ember.Route.extend
  model: (params) ->
    tps = @store.filter 'tradePair', (tp) ->
      tp.get('url_slug') == params.url_slug
    pair = tps.get('firstObject')

  setupController: (c, pair) ->
    uid = parseInt @controllerFor('auth').get('content.id')
    c.set 'model', pair

    askOrders = @store.filter 'order', (o) ->
      o.get('trade_pair_id') == parseInt(pair.get('id')) &&
      o.get('cancelled') == false &&
      o.get('complete') == false &&
      !o.get('bid')

    bidOrders = @store.filter 'order', (o) ->
      o.get('trade_pair_id') == parseInt(pair.get('id')) &&
      o.get('cancelled') == false &&
      o.get('complete') == false &&
      !!o.get('bid')

    ownOrders = @store.filter 'order', (o) ->
      o.get('trade_pair_id') == parseInt(pair.get('id')) &&
      o.get('user_id') == uid &&
      o.get('cancelled') == false &&
      o.get('complete') == false

    pairTrades = @store.filter 'trade', (o) ->
      o.get('trade_pair_id') == parseInt(pair.get('id'))

    ownTrades = @store.filter 'trade', (o) ->
      o.get('trade_pair_id') == parseInt(pair.get('id')) &&
      (o.get('ask_user_id') == uid || o.get('bid_user_id') == uid)

    @store.find('trade', {tradePair: pair.get('id')}).then (d) ->
      c.set 'pairTrades', pairTrades
      c.set 'ownTrades', ownTrades

    @store.find('order', {tradePair: pair.get('id')}).then ->
      c.set 'askOrders', askOrders
      c.set 'bidOrders', bidOrders
      c.set 'ownOrders', ownOrders

    @store.find('trade', {tradePair: pair.get('id'), user: uid}) if uid

    @ordersChannel?.unsubscribe()
    @ordersChannel = h.setupPusher(@store, 'order', "orders-#{pair.get 'id'}")

    @tradesChannel?.unsubscribe()
    @tradesChannel = h.setupPusher(@store, 'trade', "trades-#{pair.get 'id'}")

    @tradePairsChannel?.unsubscribe()
    @tradePairsChannel = h.setupPusher(@store, 'tradePair', "tradePairs")

  deactivate: ->
    @ordersChannel?.unsubscribe()
    @ordersChannel = undefined
