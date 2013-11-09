Cx.OwnOrdersComponent = Ember.Component.extend
  orders: (->
    store = @get('targetObject.store')
    store.find 'order',
      user:      @get('user').get('id')
      tradePair: @get('pair').get('id')
      complete: false
      cancelled: false

  ).property()

  actions:
    cancel: (order) ->
      order.cancel (result) -> @get('orders').removeObject(order)
