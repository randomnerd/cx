Cx.HashratesController = Em.ArrayController.extend
  sortProperties: ['rate']
  sortAscending: false
  setFilter: (->
    @store.find('hashrate', {currency_name: @get('currency.name')}).then (d) =>
      @set 'model', @store.filter 'hashrate', (o) =>
        o.get('currency.id') == @get('currency.id')
  ).observes('currency')
  setupPusher: (->
    @channel = h.setupPusher @store, 'hashrate', "hashrates-#{@get('currency.id')}", null, false
  ).observes('currency')
  limited: (->
    @get('arrangedContent').toArray().splice(0,15)
  ).property('@each')
