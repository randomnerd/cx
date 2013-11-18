Cx.BalanceChangesRoute = Ember.Route.extend
  model: (params) ->
    Ember.RSVP.hash(
      changes: @store.find 'balanceChange', {currency_name: params.name}
      currency: @store.find 'currency', {name: params.name}
    ).then (d) -> d

  setupController: (c, m) ->
    if cname = m.get? 'name'
      @store.find('balanceChange', {currency_name: cname}).then (bc) =>
        c.set 'model', bc
        c.set 'currency', m
    else
      console.log m
      c.set 'model', m.changes
      c.set 'currency', m.currency.get('content.firstObject')
