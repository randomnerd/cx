# For more information see: http://emberjs.com/guides/routing/

Cx.Router.map () ->
  @route 'tradeIndex', {path: '/'}
  @route 'tradePair', {path: '/trade/:urlSlug'}

Cx.TradePairRoute = Ember.Route.extend
  model: (params) ->
    @store.findQuery('tradePair', {urlSlug: params.urlSlug}).then (tps) ->
      tps.get('firstObject')

  setupController: (c, pair) ->
    uid = @controllerFor('auth').get('content.id')
    console.log uid
    c.set 'content', pair
    c.set 'orders', @store.find('order', {tradePair: pair.get('id')})
    c.set 'ownOrders', @store.find('order', {tradePair: pair.get('id')})
    # @store.find('order', {tradePair: pair.get('id')}).then (orders) =>
    #   c.set 'content', pair
    #   c.set 'orders', orders
    #   c.set 'ownOrders',

Cx.ApplicationRoute = Ember.Route.extend
  model: (controller) ->
    Ember.RSVP.hash({
      tradePairs: @store.findAll('tradePair')
      currencies: @store.findAll('currency')
      balances:   @store.findAll('balance')
    }).then (data) -> Ember.Object.create(data)
  setupController: (c, m) -> c.set 'model', m

  actions:
    login: -> @controllerFor("auth").login()
    logout: -> @controllerFor("auth").logout()

# Cx.Router.reopen
#   location: 'history'
