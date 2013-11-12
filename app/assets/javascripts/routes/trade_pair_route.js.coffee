Cx.TradeIndexRoute = Ember.Route.extend
  model: -> @store.findAll('tradePair')
  setupController: (c, pairs) -> c.set 'model', pairs
  actions:
    openPair: (pair) ->
      @router.transitionTo 'tradePair', pair

Cx.TradePairRoute = Ember.Route.extend
  model: (params) ->
    tps = @store.filter 'tradePair', (tp) ->
      tp.get('urlSlug') == params.urlSlug
    pair = tps.get('firstObject')

  setupController: (c, pair) ->
    window.store = @store
    window.pair = pair
    window.points = []
    window.vpoints = []
    $.ajax
      url: "/api/v1/trade_pairs/#{pair.get 'id'}/chart_items"
      type: 'GET'
      success: (data) => @store.pushPayload 'chartItem', data

    uid = parseInt @controllerFor('auth').get('content.id')
    c.set 'model', pair

    chartItems = @store.filter 'chartItem', (ci) ->
      parseInt(ci.get('tradePair.id')) == parseInt(pair.get('id'))

    c.set 'chartItems', chartItems

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
    @ordersChannel = pusher.subscribe("orders-#{pair.get 'id'}")

    @ordersChannel.bind 'order#new', (order) =>
      found = @store.getById('order', order.id)
      unless found
        @store.pushPayload 'order', orders: [order]

    @ordersChannel.bind 'order#update', (order) =>
      o = @store.getById('order', order.id)
      return if o?.get('updatedAt') > new Date(order.updated_at)
      @store.pushPayload 'order', orders: [order]

    @ordersChannel.bind 'order#delete', (order) =>
      @store.getById('order', order.id)?.deleteRecord()

    @tradesChannel?.unsubscribe()
    @tradesChannel = pusher.subscribe("trades-#{pair.get 'id'}")

    @tradesChannel.bind 'trade#new', (trade) =>
      found = @store.getById('trade', trade.id)
      unless found
        @store.pushPayload 'trade', trades: [trade]

    @tradesChannel.bind 'trade#update', (trade) =>
      o = @store.getById('trade', trade.id)
      return if o?.get('updatedAt') > new Date(trade.updated_at)
      @store.pushPayload 'trade', trades: [trade]

    @tradesChannel.bind 'trade#delete', (trade) =>
      @store.getById('trade', order.id)?.deleteRecord()

    @chart_itemsChannel?.unsubscribe()
    @chart_itemsChannel = pusher.subscribe("chartItems-#{pair.get 'id'}")

    @chart_itemsChannel.bind 'chartItem#update', (chart_item) =>
      @get('store').pushPayload 'chartItem', chart_items: [chart_item]

    @tradePairsChannel?.unsubscribe()
    @tradePairsChannel = pusher.subscribe("tradePairs")

    @tradePairsChannel.bind 'tradePair#new', (tradePair) =>
      found = @store.getById('tradePair', tradePair.id)
      unless found
        @store.pushPayload 'tradePair', tradePairs: [tradePair]

    @tradePairsChannel.bind 'tradePair#update', (tradePair) =>
      o = @store.getById('tradePair', tradePair.id)
      return if o?.get('updatedAt') > new Date(tradePair.updated_at)
      @store.pushPayload 'tradePair', tradePairs: [tradePair]

    @tradePairsChannel.bind 'tradePair#delete', (tradePair) =>
      @store.getById('tradePair', tradePair.id)?.deleteRecord()


  deactivate: ->
    @ordersChannel?.unsubscribe()
    @ordersChannel = undefined
