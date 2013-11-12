Cx.Trade = DS.Model.extend
  bid: DS.attr('boolean')
  rate: DS.attr('number')
  amount: DS.attr('number')
  created_at: DS.attr('date')
  ask_user_id: DS.attr('number')
  bid_user_id: DS.attr('number')
  trade_pair_id: DS.attr('number')
  time: (-> @get('created_at')?.toISOString()).property('created_at')
  marketAmount: (->
    h.n2f @get('amount') * @get('rate')
  ).property('amount', 'rate')
