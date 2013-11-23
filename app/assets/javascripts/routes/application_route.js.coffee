Cx.LoadingRoute = Ember.Route.extend({})
Cx.ApplicationRoute = Ember.Route.extend
  model: ->
    Ember.RSVP.hash(
      messages:   @store.findAll 'message'
      currencies: @store.findAll 'currency'
      tradePairs: @store.findAll 'tradePair'
    ).then (m) -> m
  setupController: (c, m) ->
    @controllerFor('messages').set 'model', m.messages
    @controllerFor('tradePairs').set 'model', m.tradePairs
    @controllerFor('currencies').set 'model', m.currencies

    @loadUserData(@controllerFor('auth').get('content'))

    @presenceChannel = pusher.subscribe("presence-users")
    @presenceChannel.bind 'pusher:member_added', (data) =>
      user = data.info
      user.id = data.id
      @store.pushPayload 'user', users: [user]
    @presenceChannel.bind 'pusher:member_removed', (data) =>
      @store.getById('user', data.id)?.deleteRecord()

  loadUserData: (user) ->
    return unless user
    Ember.RSVP.hash(
      balances:      @store.findAll 'balance'
      notifications: @store.findAll 'notification'
      addressBook:   @store.findAll 'addressBookItem'
    ).then (m) =>
      @controllerFor('balances').set 'model', m.balances
      @controllerFor('notifications').set 'model', m.notifications
      # @controllerFor('addressBookItems').set 'model', m.addressBook
      addressBookChannel = h.setupPusher(@store, 'addressBookItem', "private-addressBook-#{user.get('id')}")

  actions:
    loadUserData: (user) -> @loadUserData(user)
    openLoginMenu: ->
      Ember.run.later -> h.openLoginMenu()
