Cx.Block = DS.Model.extend
  number: DS.attr('number')
  currency: DS.belongsTo('currency')
  reward: DS.attr('number')
  finder: DS.attr('string')
  category: DS.attr('string')
  confirmations: DS.attr('number')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  switchpool: DS.attr('boolean')
  time: (-> @get('created_at')?.toISOString()).property('created_at')
  payouts: (->
    @store.filter 'blockPayout', (b) => b.get('block.id') == @get('id')
  ).property()

