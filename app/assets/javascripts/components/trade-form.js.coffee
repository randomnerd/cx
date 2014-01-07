Cx.TradeFormComponent = Ember.Component.extend
  currBalance: Em.computed.alias('pair.currency.balance.firstObject.amount')
  marketBalance: Em.computed.alias('pair.market.balance.firstObject.amount')
  total: (->
    a = h.f2n @get 'amount'
    r = h.f2n @get 'rate'
    h.round(h.nn2f(a*r)) || 0
  ).property('amount', 'rate')

  allowSubmit: (->
    if @get 'buy'
      t = h.f2n @get 'total'
      b = @get('currBalance')
    else
      t = h.f2n @get 'amount'
      b = @get('marketBalance')
    return false unless t
    return false if @get 'inProgress'
    b >= t && @get('total') > 0 && parseFloat(@get 'amount') >= 0.01
  ).property('total', 'amount', 'inProgress'
             'currBalance',
             'marketBalance')

  fee: (->
    return 0 if @get('user.no_fees')
    if @get('buy')
      t = h.f2n @get 'amount'
      f = @get('pair.sellFee') / 100
    else
      t = h.f2n @get 'total'
      f = @get('pair.buyFee') / 100
    h.round(h.n2f(t * f)) || 0
  ).property('total', 'amount', 'user.no_fees')

  actions:
    setTotal: (balance) ->
      rate = h.f2n(@get('rate')) || @get('bestDeal.rate')
      @set 'rate', h.n2f(rate).noExponents()
      if @get('buy')
        @set 'amount', h.round(@get('marketBalance') / rate).noExponents()
      else
        @set 'amount', h.n2f(@get('currBalance')).noExponents()
    submit: ->
      store = @get('targetObject.store')
      order = store.createRecord 'order',
        bid:           !!@get('buy')
        user:          @get('user').get('content').get('content')
        rate:          h.f2n(@get('rate'))
        amount:        h.f2n(@get('amount'))
        trade_pair_id: @get('pair.id')
      order.save().then(
        type = if @get('buy') then 'buy' else 'sell'
        (=> h.ga_track('Order', @get('pair.url_slug'), "#{@get('user.email')}: new #{type}, #{@get('amount')} @ #{@get('rate')}"))
        (=> @set 'inProgress', false)
      )
