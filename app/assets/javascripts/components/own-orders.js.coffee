Cx.OwnOrdersComponent = Ember.Component.extend
  actions:
    cancel: (order) ->
      @set 'inProgress', true
      order.cancel (result) =>
        @get('controllers.orders').removeObject(order)
        @set 'inProgress', false
