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

    @presenceChannel = pusher.subscribe("presence-users")

    @presenceChannel.bind 'pusher:member_added', (data) =>
      user = data.info
      user.id = data.id
      @store.pushPayload 'user', users: [user]

    @presenceChannel.bind 'pusher:member_removed', (data) =>
      @store.getById('user', data.id)?.deleteRecord()

  actions:
    login: -> @controllerFor("auth").login()
    logout: -> @controllerFor("auth").logout()
