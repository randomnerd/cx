Cx.BalancesController = Ember.ArrayController.extend
  tradePairId: null
  needs: ['auth', 'currencies']
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'balance', "private-balances-#{uid}"
  ).on('init').observes('controllers.auth.id')
  sortProperties: ['currency.name']
  selectedCurrency: Ember.ObjectProxy.create()
  actions:
    newAddress: (currency) ->
      currency.set 'generating', true
      $.ajax
        url: "/api/v1/currencies/#{currency.get('id')}/generate_address"
        type: "POST"
        success: (data) =>
          currency.set 'generating', false
        error: (data) =>
          currency.set 'generating', false

    withdraw: (currency) ->
      @set 'selectedCurrency.content', currency
      $('#withdrawal-box').modal('show')
