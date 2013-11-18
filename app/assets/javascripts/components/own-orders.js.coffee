Cx.OwnOrdersComponent = Ember.Component.extend
  actions:
    cancel: (order) ->
      order.cancel (result) -> @get('controllers.orders').removeObject(order)
