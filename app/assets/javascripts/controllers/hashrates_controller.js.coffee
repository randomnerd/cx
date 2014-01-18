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
  pusherChannel: (-> "hashrates-#{@get('currency.id')}").property('currency.id')
  setupPusher: (->
    return unless @get('currency.id')
    @stopPusher()
    @set 'channel', h.setupPusher @store, 'hashrate', @get('pusherChannel'), null, false
  ).observes('currency')
  stopPusher: -> try pusher.unsubscribe(@get('pusherChannel'))

  limited: (->
    rates = @get('arrangedContent').toArray().splice(0,15)
    unless _.find(rates, (d) => d.get('name') == @get('user.nickname'))
      return rates unless rate = @get('currency.ownHashrate')
      rates.push
        name: @get('user.nickname')
        rate: rate
        currency: @get('currency')
        user_id: parseInt(@get('user.id'))

    rates
  ).property('@each')
