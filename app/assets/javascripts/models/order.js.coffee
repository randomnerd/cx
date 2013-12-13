Cx.Order = DS.Model.extend
  user_id: DS.attr('number')
  trade_pair_id: DS.attr('number')
  amount: DS.attr('number')
  cancelled: DS.attr('boolean')
  complete: DS.attr('boolean')
  filled: DS.attr('number')
  bid:    DS.attr('boolean')
  rate: DS.attr('number')
  updated_at: DS.attr('date')
  created_at: DS.attr('date')
  unmatchedAmount: (->
    @get('amount') - (@get('filled') || 0)
  ).property('amount', 'filled')

  marketAmount: (->
    h.nn2f((@get('unmatchedAmount') || 0) * (@get('rate') || 0))
  ).property('unmatchedAmount', 'rate')

  cancel: (cb) ->
    $.ajax
      url: "/api/v2/orders/#{@get 'id'}/cancel"
      type: "POST"
      success: (data) =>
        @transitionTo('deleted.saved')
        cb()
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'cancel failed'
        cb()


Cx.Order.FIXTURES = [
  {
    id: 1
    user: 1
    tradePair: 1
    amount: 1000000000
    rate: 1200000
    bid: true
    filled: 0
    created_at: new Date()
  }
]
