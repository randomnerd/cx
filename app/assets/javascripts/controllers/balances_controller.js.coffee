Cx.BalancesController = Ember.Controller.extend
  currencies: (-> @store.findAll 'currency').property()
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
