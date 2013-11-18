Cx.MessagesController = Em.ArrayController.extend
  sortProperties: ['created_at']
  setupPusher: (->
    h.setupPusher @store, 'message', 'messages'
  ).on('init')
