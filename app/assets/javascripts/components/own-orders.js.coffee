Cx.OwnOrdersComponent = Ember.Component.extend
  actions:
    cancel: (order) ->
      @set 'inProgress', true
      order.cancel (result) => @set 'inProgress', false
