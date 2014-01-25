Cx.BlockController = Em.ObjectController.extend
  validityMessage: (->
    switch @get 'category'
      when 'generate' then 'Confirmed!'
      when 'orphan'   then 'Orphan :('
      when 'immature' then @get('confirmations')
  ).property('confirmations', 'category')
  validityClass: (->
    switch @get 'category'
      when 'generate' then 'success'
      when 'orphan'   then  'danger'
  ).property('category')
  orphan: (-> @get('category') == 'orphan').property('category')
  payout: (->
    @get('payouts.firstObject')
  ).property('payouts.@each', 'payouts.@each.reward')
