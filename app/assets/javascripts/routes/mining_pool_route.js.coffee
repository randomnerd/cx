Cx.MiningPoolRoute = Em.Route.extend
  model: (params) ->
    @store.find('currency', {name: params.name}).then (d) ->
      d.get('firstObject')
  setupController: (c, m) ->
    @store.find('block', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('blocks').set 'model', @store.filter 'block', (o) =>
        o.get('currency.id') == m.get('id')

    @store.find('blockPayout', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('blockPayouts').set 'model', @store.filter 'blockPayout', (o) =>
        o.get('currency.id') == m.get('id')

    @store.find('hashrate', {currency_name: m.get('name')}).then (d) =>
      @controllerFor('hashrates').set 'model', @store.filter 'hashrate', (o) =>
        o.get('currency.id') == m.get('id')

    @controllerFor('blocks').set('currency', m)
    @controllerFor('hashrates').set('currency', m)
    @controllerFor('blockPayouts').set('currency', m)
    c.set 'currency', m

  activate: ->
    @controllerFor('blocks').setupPusher()
    @controllerFor('hashrates').setupPusher()
    @controllerFor('blockPayouts').setupPusher()

  deactivate: ->
    @controllerFor('blocks').get('channel').unsubscribe()
    @controllerFor('hashrates').get('channel').unsubscribe()
    @controllerFor('blockPayouts').get('channel').unsubscribe()
