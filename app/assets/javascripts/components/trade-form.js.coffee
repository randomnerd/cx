Cx.TradeFormComponent = Ember.Component.extend
  total: (->
    a = h.f2n @get 'amount'
    r = h.f2n @get 'rate'
    h.round(h.nn2f(a*r)) || 0
  ).property('amount', 'rate')

  fee: (->
    if @get('buy')
      t = h.f2n @get 'amount'
      f = @get('pair')?.get('sellFee') / 100
    else
      t = h.f2n @get 'total'
      f = @get('pair')?.get('buyFee') / 100
    h.round(h.n2f(t * f)) || 0
  ).property('total', 'amount')

  actions:
    setTotal: (balance) ->
      @set 'amount', balance
    submit: ->
      store = @get('targetObject.store')
      order = store.createRecord 'order',
        user:      @get('user').get('content').get('content')
        tradePair: @get('pair')
        rate:      h.f2n(@get('rate'))
        amount:    h.f2n(@get('amount'))
        bid:       !!@get('buy')
      order.save()

