Cx.TradePairRoute = Ember.Route.extend
  model: (params) ->
    tps = @store.filter 'tradePair', (tp) ->
      tp.get('urlSlug') == params.urlSlug
    pair = tps.get('firstObject')

  setupController: (c, pair) ->
    uid = @controllerFor('auth').get('content.id')
    c.set 'model', pair
    askOrders =  @store.filter 'order', (o) ->
      o.get('tradePairId') == parseInt(pair.get('id')) &&
      o.get('cancelled') == false &&
      o.get('complete') == false &&
      !o.get('bid')

    bidOrders =  @store.filter 'order', (o) ->
      o.get('tradePairId') == parseInt(pair.get('id')) &&
      o.get('cancelled') == false &&
      o.get('complete') == false &&
      !!o.get('bid')

    ownOrders = @store.filter 'order', (o) ->
      o.get('tradePairId') == parseInt(pair.get('id')) &&
      o.get('userId') == parseInt(uid) &&
      o.get('cancelled') == false &&
      o.get('complete') == false

    @store.find('order', {tradePair: pair.get('id')}).then ->
      c.set 'askOrders', askOrders
      c.set 'bidOrders', bidOrders
      c.set 'ownOrders', ownOrders

    ordersChannel = pusher.subscribe("orders-#{pair.get 'id'}")

    ordersChannel.bind 'order#new', (order) =>
      found = @store.getById('order', order.id)
      unless found
        @store.pushPayload 'order', orders: [order]

    ordersChannel.bind 'order#update', (order) =>
      o = @store.getById('order', order.id)
      return if o?.get('updatedAt') > new Date(order.updated_at)
      @store.pushPayload 'order', orders: [order]

    ordersChannel.bind 'order#delete', (order) =>
      @store.getById('order', order.id)?.deleteRecord()
