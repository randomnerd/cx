Cx.BlocksController = Em.ArrayController.extend
  sortProperties: ['number']
  sortAscending: false
  setupPusher: (->
    # @stopPusher()
    @channel = h.setupPusher @store, 'block', "blocks-#{@get('currency.id')}", null, false
  ).observes('currency')
  limited: (->
    @get('arrangedContent').toArray().splice(0,20)
  ).property('@each')
