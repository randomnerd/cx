Cx.BalanceHistoryRoute = Ember.Route.extend
  model: (params) ->
    currency = @store.filter('currency',
      (c) -> c.get('name') == params.name).get('firstObject')

  setupController: (c, currency) ->
    @store.find 'balanceChange', {currency_id: currency.get('id')}
    balance = @store.filter('balance',
      (c) -> c.get('currency.id') == currency.get('id')).get('firstObject')
    items = @store.filter 'balanceChange', (item) ->
      item.get('balance.id') == balance.get('id')
    uid = parseInt @controllerFor('auth').get('content.id')
    c.set 'content', items
    c.set 'currency', currency
