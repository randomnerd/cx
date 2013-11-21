Cx.BalancesRoute = Cx.AuthRoute.extend({})
Cx.BalanceChangesRoute = Cx.AuthRoute.extend
  model: (params) ->
    @store.find('currency', {name: params.name}).then (d) ->
      d.get('firstObject')

  setupController: (c, m) ->
    @store.find('balanceChange', {currency_name: m.get('name')}).then (bc) =>
      c.set 'model', Em.ArrayProxy.create(bc)
      c.set 'currency', m
