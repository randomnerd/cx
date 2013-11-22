Cx.DepositsController = Em.ArrayController.extend
  needs: ['auth']
  sortProperties: ['num_id']
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'deposit', "private-deposits-#{uid}", @
  ).on('init').observes('controllers.auth.id')
  unprocessed: (->
    @filter (o) -> o.get('processed') == false
  ).property('@each.processed')
