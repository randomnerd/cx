Cx.BlockPayoutsController = Em.ArrayController.extend
  needs: ['auth']
  user: Em.computed.alias('controllers.auth.content')
  setFilter: (->
    @store.find('blockPayout', {currency_name: @get('currency.name')}).then (d) =>
      @set 'model', @store.filter 'block', (o) =>
        o.get('currency_id') == parseInt(@get('currency.id'))
  ).observes('currency')
  setupPusher: (->
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'blockPayout', "private-blockpayouts-#{@get('user.id')}"
  ).observes('currency', 'user.id')
