Cx.BalanceChange = DS.Model.extend
  amount: DS.attr('number')
  held: DS.attr('number')
  balance: DS.belongsTo('balance')
  t_held: DS.attr('number')
  t_amount: DS.attr('number')
  comment: DS.attr('string')
  subject_type: DS.attr('string')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  vs_currency: DS.attr('string')
  vs_rate:     DS.attr('string')
  time: (-> @get('created_at')?.toISOString()).property('created_at')
  positive: (-> @get('amount') > 0).property('amount')
  source: (->
    s = @get('subject_type') || @get('comment')
    if @get('vs_currency') && @get('vs_rate')
      s += " #{@get 'vs_currency'} @ #{h.round(h.n2f @get('vs_rate'))}"
    s
  ).property('subject_type', 'comment', 'vs_currency', 'vs_rate')
  num_id: (-> parseInt(@get 'id')).property('id')