Cx.PoolRowController = Cx.CurrencyController.extend
  needs: ['miningIndex']
  mining_score_padded: (->
    parseFloat(@get('mining_score')).toFixed(2)
  ).property('mining_score')
  last_block_time: (->
    @get('last_block_at')?.toISOString()
  ).property('last_block_at')

  actions:
    openStats: (curr) ->
      # dirty hack
      @get('controllers.miningIndex').send('openStats', curr)
