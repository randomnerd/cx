Cx.OrderBookComponent = Ember.Component.extend
  bookMaxLen: 20
  currBalance:   Em.computed.alias('pair.currency.balance.firstObject.amount')
  marketBalance: Em.computed.alias('pair.market.balance.firstObject.amount')
  orderBook: (->
    return unless @orders
    book = {}
    ret = []
    orders = @orders.filter (o) =>
      o.get('bid') == @buy &&
      o.get('cancelled') == false &&
      o.get('complete') == false

    orders = orders.reverse() if @buy

    for order in orders
      len = _.keys(book).length
      newlen = !book[order.get('rate')]
      break if newlen && len == @bookMaxLen
      b = book[order.get('rate')] ||= {amount: 0, marketAmount: 0}
      b.amount = b.amount + order.get('unmatchedAmount') || 0
      b.marketAmount = b.marketAmount + order.get('marketAmount') || 0
      b.own ||= order.get('user_id') == parseInt(@user.get('id'))

    for rate, order of book
      ret.push
        own: order.own
        rate: parseFloat(rate)
        amount: h.round(order.amount)
        marketAmount: h.round(order.marketAmount)

    book = _.sortBy(ret, (o) -> o.rate)
    if @buy then book.reverse() else book

  ).property('orders.@each.filled', 'orders.@each.complete', 'orders.@each.cancelled', 'user.id')
  actions:
    setForms: (order) ->
      rate    = order.rate
      drate   = h.n2f(rate).noExponents()
      orders  = @get('orderBook').filter (o) =>
        if @buy then o.rate >= order.rate else o.rate <= order.rate

      sum_amt = 0
      mkt_amt = 0
      for order in orders
        sum_amt += order.amount
        mkt_amt += h.f2n(order.marketAmount)
        if @buy && sum_amt > @get('currBalance')
          sum_amt = @get('currBalance')
          mkt_amt = h.nn2n(sum_amt * rate)
          break
        else if !@buy && mkt_amt > @get('marketBalance')
          mkt_amt = @get('marketBalance')
          sum_amt = h.f2n(mkt_amt / rate)
          break

        # too precise :(
        # if @buy && sum_amt + order.amount > @get('currBalance')
        #   sa = @get('currBalance') - sum_amt
        #   ma = h.nn2n(sa * order.rate)
        #   done = true
        # else if !@buy && mkt_amt + h.f2n(order.marketAmount) > @get('marketBalance')
        #   ma = @get('marketBalance') - mkt_amt
        #   sa = h.f2n(ma / order.rate)
        #   done = true
        # else
        #   sa = order.amount
        #   ma = h.f2n(order.marketAmount)
        # sum_amt += sa
        # mkt_amt += ma
        # break if done

      amount     = h.n2f(sum_amt).noExponents()
      mkt_amount = h.n2f(mkt_amt).noExponents()

      @set('askRate', drate)
      @set('bidRate', drate)
      if @buy
        @set('askAmount', amount)
        Em.run.next => @set('askTotal', mkt_amount)
      else
        @set('bidAmount', amount)
        Em.run.next => @set('bidTotal', mkt_amount)

