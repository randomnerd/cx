Cx.MessagesRoute = Ember.Route.extend
  model: -> @store.findAll('message')
