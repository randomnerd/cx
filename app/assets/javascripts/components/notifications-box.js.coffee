Cx.NotificationsBoxComponent = Ember.Component.extend
  ctrl: Ember.ArrayController.create
    sortProperties: ['created_at']
    sortAscending: false
  unack: (->
    @get('items')?.any (n) -> !n.get('ack')
  ).property('items.@each.ack')
  sortedItems: (->
    @get('ctrl').set('content', @get('items'))
    @get('ctrl.arrangedContent')
  ).property('items', 'items.@each')

  actions:
    ackAll: ->
      $.ajax
        url: "/api/v1/notifications/ack_all"
        type: "POST"
        success: (data) =>
          rec.set('ack', true) for rec in @get('items.content')

    removeAll: ->
      $.ajax
        url: "/api/v1/notifications/del_all"
        type: "POST"
        success: (data) =>
          @get('items').forEach =>
            rec = @get('items.firstObject')
            rec?.transitionTo('deleted.saved')


    ack: (n) ->
      n.set('ack', true)
      n.save()
    remove: (n) ->
      n.deleteRecord()
      n.save()
      @items.removeRecord(n)
