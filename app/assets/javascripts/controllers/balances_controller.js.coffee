Cx.BalancesController = Ember.Controller.extend
  currencies: (-> @store.findAll 'currency').property()
  selectedCurrency: Ember.ObjectProxy.create()
  actions:
    withdraw: (currency) ->
      @set 'selectedCurrency.content', currency
      $('#withdrawal-box').modal('show')
