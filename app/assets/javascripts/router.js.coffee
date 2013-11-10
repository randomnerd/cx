# For more information see: http://emberjs.com/guides/routing/

Cx.Router.map () ->
  @route 'tradeIndex', {path: '/'}
  @route 'tradePair', {path: '/trade/:urlSlug'}

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

Cx.ApplicationRoute = Ember.Route.extend
  model: (controller) ->
    Ember.RSVP.hash({
      tradePairs: @store.findAll('tradePair')
      currencies: @store.findAll('currency')
      balances:   @store.findAll('balance')
    }).then (data) -> Ember.Object.create(data)
  setupController: (c, m) ->
    c.set 'model', m
    user = @controllerFor('auth').get('content.content')
    return unless user
    balancesChannel = pusher.subscribe("private-balances-#{user.get('id')}")

    balancesChannel.bind 'balance#new', (balance) =>
      found = @store.getById('balance', balance.id)
      unless found
        @store.pushPayload 'balance', balances: [balance]

    balancesChannel.bind 'balance#update', (balance) =>
      o = @store.getById('balance', balance.id)
      return if o?.get('updatedAt') > new Date(balance.updated_at)
      @store.pushPayload 'balance', balances: [balance]

    balancesChannel.bind 'balance#delete', (balance) =>
      @store.getById('balance', balance.id)?.deleteRecord()

  actions:
    login: -> @controllerFor("auth").login()
    logout: -> @controllerFor("auth").logout()

# Cx.Router.reopen
#   location: 'history'
