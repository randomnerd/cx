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
      book[order.get('rate')] ||= {amount: 0, marketAmount: 0}
      book[order.get('rate')].amount += order.get('unmatchedAmount') || 0
      book[order.get('rate')].marketAmount += order.get('marketAmount') || 0
      book[order.get('rate')].own ||= order.get('user_id') == parseInt(@user.get('id'))

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
      $('.tradeColumn .rate-input').val(h.n2f(o.rate)).trigger('keyup')
      $('.tradeColumn .amount-input').val(h.n2f(o.amount)).trigger('keyup')

