Ember.Application.initializer
  name: 'auth'

  initialize: (container) ->
    store = container.lookup('store:main')
    attributes = $('meta[name="current-user"]').attr('content')
    if attributes
      data = JSON.parse(attributes)
      data.masq = $('meta[name="masquerade"]').attr('content')
      object = store.push(Cx.User, data)
      user = store.find(Cx.User, object.id)

    container.lookup('controller:auth').set('model', user)
    container.typeInjection('controller', 'currentUser', 'controller:auth')
