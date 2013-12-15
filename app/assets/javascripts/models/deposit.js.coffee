Cx.Deposit = DS.Model.extend
  amount: DS.attr('number')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  currency: DS.belongsTo('currency')
  confirmations: DS.attr('number')
  processed: DS.attr('boolean')
  txid: DS.attr('string')
  time: (-> @get('created_at')?.toISOString()).property('created_at')
  num_id: (-> parseInt(@get 'id')).property('id')
