Cx.MiningPoolRoute = Em.Route.extend
  model: (params) ->
    @store.find('currency', {name: params.name}).then (d) ->
      d.get('firstObject')
  setupController: (c, m) ->
    @controllerFor('blocks').set 'model', []
    @controllerFor('blockPayouts').set 'model', []
    @controllerFor('hashrates').set 'model', []

    @store.find('block', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('blocks').set 'model', Em.ArrayProxy.create(d)

    if @controllerFor('auth').get('isSignedIn')
      @store.find('blockPayout', {currency_name: m.get('name')}).then (d) =>
        @controllerFor('blockPayouts').set 'model', Em.ArrayProxy.create(d)
      @controllerFor('blockPayouts').set('currency', m)

    @store.find('hashrate', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('hashrates').set 'model', Em.ArrayProxy.create(d)

    @controllerFor('blocks').set('currency', m)
    @controllerFor('hashrates').set('currency', m)
    c.set 'currency', m

  activate: ->
    @controllerFor('blocks').setupPusher()
    @controllerFor('hashrates').setupPusher()

  deactivate: ->
    @controllerFor('blocks').stopPusher()
    @controllerFor('hashrates').stopPusher()
