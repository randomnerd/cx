Cx.BalancesRoute = Cx.AuthRoute.extend({})
Cx.BalanceChangesRoute = Cx.AuthRoute.extend
  model: (params) ->
    @store.find('currency', {name: params.name}).then (d) ->
      d.get('firstObject')

  setupController: (c, m) ->
    c.set 'currency', m
    c.set 'model', []
    @store.find('deposit', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('deposits').set 'model', Em.ArrayProxy.create(d)
    @store.find('balanceChange', {currency_name: m.get('name')}).then (bc) =>
      c.set 'model', Em.ArrayProxy.create(bc)
