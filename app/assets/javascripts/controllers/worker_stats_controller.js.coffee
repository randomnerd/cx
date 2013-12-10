Cx.WorkerStatsController = Em.ArrayController.extend
  needs: ['auth']
  # setupPusher: (->
  #   console.log 'ws init'
  #   return unless uid = @get 'controllers.auth.id'
  #   @channel?.unsubscribe()
  #   @channel = h.setupPusher @store, 'workerStat', "private-worker-stats-#{uid}"
  # ).on('init').observes('controllers.auth.id')
