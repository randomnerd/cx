Cx.WorkersController = Em.ArrayController.extend
  needs: ['auth']
  # sortProperties: ['name']
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'worker', "private-workers-#{uid}"
  ).on('init').observes('controllers.auth.id')

  actions:
    newWorker: -> @store.createRecord('worker')
