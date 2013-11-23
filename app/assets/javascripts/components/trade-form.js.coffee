Cx.TradeFormComponent = Ember.Component.extend
  total: (->
    a = h.f2n @get 'amount'
    r = h.f2n @get 'rate'
    h.round(h.nn2f(a*r)) || 0
  ).property('amount', 'rate')

  allowSubmit: (->
    if @get 'buy'
      t = h.f2n @get 'total'
      b = @get('pair.market.balance.firstObject.amount')
    else
      t = h.f2n @get 'amount'
      b = @get('pair.currency.balance.firstObject.amount')
    return false unless t
    return false if @get 'inProgress'
    b >= t && @get('total') > 0 && parseFloat(@get 'amount') >= 0.01
  ).property('total', 'amount', 'inProgress'
             'pair.currency.balance.firstObject.amount',
             'pair.market.balance.firstObject.amount')

  fee: (->
    if @get('buy')
      t = h.f2n @get 'amount'
      f = @get('pair.sellFee') / 100
    else
      t = h.f2n @get 'total'
      f = @get('pair.buyFee') / 100
    h.round(h.n2f(t * f)) || 0
  ).property('total', 'amount')

  actions:
    setTotal: (balance) ->
      @set 'amount', h.n2f(balance)
    submit: ->
      @set 'inProgress', true
      store = @get('targetObject.store')
      order = store.createRecord 'order',
        user:      @get('user').get('content').get('content')
        trade_pair_id: @get('pair.id')
        rate:      h.f2n(@get('rate'))
        amount:    h.f2n(@get('amount'))
        bid:       !!@get('buy')
      order.save().then => @set 'inProgress', false
