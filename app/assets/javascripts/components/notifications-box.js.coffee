Cx.NotificationsBoxComponent = Ember.Component.extend
  unack: (->
    @get('items.unAck.length') > 0
  ).property('items.unAck.length')

  actions:
    ackAll: ->
      $.ajax
        url: "/api/v2/notifications/ack_all"
        type: "POST"
        success: (data) =>
          @get('items.unAck').forEach (rec) =>
            rec?.set 'ack', true

    removeAll: ->
      $.ajax
        url: "/api/v2/notifications/del_all"
        type: "POST"
        success: (data) =>
          @get('items').forEach (rec) =>
            rec.transitionTo('deleted.saved')


    ack: (n) ->
      n.set('ack', true)
      n.save()
    remove: (n) ->
      n.deleteRecord()
      n.save()
      @items.removeRecord(n)
