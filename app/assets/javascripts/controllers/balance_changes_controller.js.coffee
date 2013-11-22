Cx.BalanceChangesController = Em.ArrayController.extend
  sortProperties: ['num_id']
  sortAscending: false
  needs: ['auth', 'deposits']
  deposits: Em.computed.alias('controllers.deposits.unprocessed')
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'balanceChange', "private-balanceChanges-#{uid}", @
  ).on('init').observes('controllers.auth.id')
  filter: (o) -> o.get('currency_id') == parseInt(@get('currency.id'))
  setFilter: (->
    @set 'model', @store.filter 'balanceChange', (o) => @filter(o)
  ).on('init').observes('currency.id')
  addObject: (o) ->
    return unless @filter(o)
    @_super(o)
