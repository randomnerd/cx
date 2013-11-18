Cx.NotificationsController = Em.ArrayController.extend
  sortProperties: ['created_at']
  sortAscending: false
  needs: ['auth']
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'notification', "private-notifications-#{uid}"
  ).on('init').observes('controllers.auth.id')
  unAck: (->
    @store.filter 'notification', (o) -> !o.get('ack')
  ).property('model.@each.ack')
