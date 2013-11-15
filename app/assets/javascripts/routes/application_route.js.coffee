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
    messagesChannel = h.setupPusher(@store, 'message', 'messages')

    user = @controllerFor('auth').get('content.content')
    return unless user
    balancesChannel = h.setupPusher(@store, 'balance', "private-balances-#{user.get('id')}")
    balanceChangesChannel = h.setupPusher(@store, 'balanceChange', "private-balanceChanges-#{user.get('id')}")
    notifChannel = h.setupPusher(@store, 'notification', "private-notifications-#{user.get('id')}")
    addressBookChannel = h.setupPusher(@store, 'addressBookItem', "private-addressBook-#{user.get('id')}")
    tradePairsChannel = h.setupPusher(@store, 'tradePair', "tradePairs")

    @presenceChannel = pusher.subscribe("presence-users")

    @presenceChannel.bind 'pusher:member_added', (data) =>
      user = data.info
      user.id = data.id
      @store.pushPayload 'user', users: [user]

    @presenceChannel.bind 'pusher:member_removed', (data) =>
      @store.getById('user', data.id)?.deleteRecord()

    notifications = @store.filter 'notification', -> true
    unAckNotif = @store.filter 'notification', (n) -> !n.get('ack')

    @store.findAll('addressBookItem')

    @store.find('notification', {user_id: user.id}).then (d) =>
      @controllerFor('commonNavbar').set 'notifications', notifications
      @controllerFor('commonNavbar').set 'unAckNotif', unAckNotif

  actions:
    openLoginMenu: ->
      Ember.run.later -> h.openLoginMenu()
    login: -> @controllerFor("auth").login()
    logout: -> @controllerFor("auth").logout()
