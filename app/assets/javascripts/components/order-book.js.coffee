Cx.OrderBookComponent = Ember.Component.extend
  orderBook: (->
    return unless @orders
    book = {}
    ret = []
    orders = @orders.filter (o) =>
      o.get('bid') == @buy &&
      o.get('cancelled') == false &&
      o.get('complete') == false
    orders.forEach (order) =>
      b = book[order.get('rate')] ||= {amount: 0, marketAmount: 0}
      b.amount = b.amount + order.get('unmatchedAmount') || 0
      b.marketAmount = b.marketAmount + order.get('marketAmount') || 0
      b.own ||= order.get('user_id') == parseInt(@user.get('id'))

    for rate, order of book
      ret.push
        own: order.own
        rate: rate
        amount: h.round(order.amount)
        marketAmount: h.round(order.marketAmount)

    if @buy then ret.reverse() else ret
  ).property('orders.@each.filled', 'user.id')
  actions:
    setForms: (o) ->
      $('.tradeColumn .rate-input').val(h.n2f(o.rate).noExponents()).trigger('keyup')
      $('.tradeColumn .amount-input').val(h.n2f(o.amount).noExponents()).trigger('keyup')

