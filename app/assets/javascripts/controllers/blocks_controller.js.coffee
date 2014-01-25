Cx.BlocksController = Em.ArrayController.extend
  sortProperties: ['created_at']
  sortAscending: false
  pusherChannel: (-> "blocks-#{@get('currency.id')}").property('currency.id')
  setupPusher: (->
    return unless @get('currency.id')
    @stopPusher()
    @channel = h.setupPusher @store, 'block', @get('pusherChannel'), @, false
  ).observes('currency')
  limited: (->
    @get('arrangedContent').toArray().splice(0,20)
  ).property('@each', '@each.confirmations', '@each.category')
  stopPusher: -> try pusher.unsubscribe(@get('pusherChannel'))
