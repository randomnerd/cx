Cx.ApplicationRoute = Ember.Route.extend
  model: (controller) ->
    Ember.RSVP.hash({
      tradePairs: @store.findAll('tradePair')
      currencies: @store.findAll('currency')
      balances:   @store.findAll('balance')
    }).then (data) -> Ember.Object.create(data)
  setupController: (c, m) ->
    c.set 'model', m
    @controllerFor('commonChat').set('model', @store.findAll('message'))

    user = @controllerFor('auth').get('content.content')
    return unless user
    balancesChannel = h.setupPusher(@store, 'balance', "private-balances-#{user.get('id')}")
    @presenceChannel = pusher.subscribe("presence-users")

    @presenceChannel.bind 'pusher:member_added', (data) =>
      user = data.info
      user.id = data.id
      @store.pushPayload 'user', users: [user]

    @presenceChannel.bind 'pusher:member_removed', (data) =>
      @store.getById('user', data.id)?.deleteRecord()

  actions:
    openLoginMenu: ->
      Ember.run.later -> h.openLoginMenu()
    login: -> @controllerFor("auth").login()
    logout: -> @controllerFor("auth").logout()
