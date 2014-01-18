Cx.PoolRowController = Cx.CurrencyController.extend
  needs: ['miningIndex']
  actions:
    openStats: (curr) ->
      # dirty hack
      @get('controllers.miningIndex').send('openStats', curr)
