Cx.BalancesRoute = Cx.AuthRoute.extend({})
Cx.BalanceChangesRoute = Cx.AuthRoute.extend
  model: (params) ->
    @store.find('currency', {name: params.name}).then (d) ->
      d.get('firstObject')

  setupController: (c, m) ->
    c.set 'page', 1
    c.set 'currency', m
    c.set 'model', []
    @store.find('deposit', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('deposits').set 'model', Em.ArrayProxy.create(d)
    @store.find('balanceChange', {currency_name: m.get('name')}).then (bc) =>
      c.set 'model', Em.ArrayProxy.create(bc)

  actions:
    getMore: ->
      c = @get 'controller'
      nextPage = c.get('page') + 1
      @store.find('balanceChange',
        currency_name: c.get('currency.name')
        page: nextPage
      ).then (d) ->
        c.set('loadingMore', false)
        return unless d.get('length')
        c.addObjects(d)
        c.set('page', nextPage)
