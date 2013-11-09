Cx.Order = DS.Model.extend
  user: DS.belongsTo('user')
  tradePair: DS.belongsTo('tradePair')
  amount: DS.attr('number')
  filled: DS.attr('number')
  bid:    DS.attr('boolean')
  rate: DS.attr('number')
  created_at: DS.attr('date')
  unmatchedAmount: (->
    @get('amount') - @get('filled')
  ).property('amount', 'filled')

  marketAmount: (->
    h.nn2f(@get('unmatchedAmount') * @get('rate'))
  ).property('unmatchedAmount', 'rate')

  cancel: (cb) ->
    console.log 'cancel', @
    $.ajax
      url: "/api/v1/orders/#{@get 'id'}/cancel"
      type: "POST"
      success: (data) =>
        window.order = @
        @deleteRecord()
        console.log 'cancel succeeded'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'cancel failed'


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
