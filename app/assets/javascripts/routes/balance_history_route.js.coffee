Cx.BalancesRoute = Cx.AuthRoute.extend({})
Cx.BalanceChangesRoute = Cx.AuthRoute.extend
  model: (params) ->
    Ember.RSVP.hash(
      changes: @store.find 'balanceChange', {currency_name: params.name}
      currency: @store.find 'currency', {name: params.name}
    ).then (d) -> d

  setupController: (c, m) ->
    if cname = m.get? 'name'
      @store.find('balanceChange', {currency_name: cname}).then (bc) =>
        c.set 'model', Em.ArrayProxy.create(bc)
        c.set 'currency', m
    else
      c.set 'model', Em.ArrayProxy.create(m.changes)
      c.set 'currency', m.currency.get('content.firstObject')
