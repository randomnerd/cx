Cx.OwnOrdersComponent = Ember.Component.extend
  ownOrders: (->
    @get('orders')
  ).property('orders', 'user.id')
  actions:
    cancel: (order) ->
      order.cancel (result) -> @get('orders').removeObject(order)
