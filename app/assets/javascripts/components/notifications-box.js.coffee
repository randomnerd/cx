Cx.NotificationsBoxComponent = Ember.Component.extend
  unack: (->
    @get('items.unAck.length') > 0
  ).property('items.unAck.length')

  actions:
    ackAll: ->
      $.ajax
        url: "/api/v1/notifications/ack_all"
        type: "POST"
        success: (data) =>
          @get('items.unAck').forEach =>
            rec = @get('items.unAck.firstObject')
            rec?.set 'ack', true

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
