Cx.HashratesController = Em.ArrayController.extend
  needs: ['auth']
  user: Em.computed.alias('controllers.auth.content')
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
    rates = @get('arrangedContent').toArray().splice(0,15)
    unless _.find(rates, (d) => d.get('name') == @get('user.nickname'))
      return unless rate = @get('currency.ownHashrate')
      rates.push @store.createRecord('hashrate', {
        name: @get('user.nickname')
        rate: rate
        currency: @get('currency')
        user_id: parseInt(@get('user.id'))
      })
    rates
  ).property('@each')
