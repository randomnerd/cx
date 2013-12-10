Cx.BlockPayoutsController = Em.ArrayController.extend
  setFilter: (->
    @store.find('blockPayout', {currency_name: @get('currency.name')}).then (d) =>
      @set 'model', @store.filter 'block', (o) =>
        o.get('currency_id') == parseInt(@get('currency.id'))
  ).observes('currency')
  setupPusher: (->
    @channel = h.setupPusher @store, 'blockPayout', "blockpayouts-#{@get('currency.id')}"
  ).observes('currency')
