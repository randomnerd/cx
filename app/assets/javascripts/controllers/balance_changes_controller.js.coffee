Cx.BalanceChangesController = Em.ArrayController.extend
  sortProperties: ['created_at']
  sortAscending: false
  needs: ['auth']
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'balanceChange', "private-balanceChanges-#{uid}"
  ).on('init').observes('controllers.auth.id')
  setFilter: (->
    @set 'model', @store.filter 'balanceChange', (o) =>
      o.get('currency_id') == parseInt(@get('currency.id')) &&
      o.get('amount') > 0
  ).on('init').observes('currency.id')
