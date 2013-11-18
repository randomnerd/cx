Ember.Application.initializer
  name: 'auth'

  initialize: (container) ->
    store = container.lookup('store:main')
    attributes = $('meta[name="current-user"]').attr('content')
    if attributes
      object = store.push(Cx.User, JSON.parse(attributes))
      user = store.find(Cx.User, object.id)

    container.lookup('controller:auth').set('model', user)
    container.typeInjection('controller', 'currentUser', 'controller:auth')
