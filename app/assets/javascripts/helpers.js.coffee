@h ||= {}

@h.f2n = (f) -> Math.round(f * Math.pow(10, 8))
@h.n2f = (n) -> n / Math.pow(10,8)
@h.nn2n = (n) -> Math.round(n / Math.pow(10,8))
@h.nn2f = (n) -> n / Math.pow(10,16)

@h.round = (amount, precision = 8) ->
  amount * Math.pow(10, precision) / Math.pow(10, precision)

@h.openLoginMenu = -> $('#login-menu-link').dropdown('toggle')
@h.postInProgress ||= false
@h.pushedModels ||= []
@h.postDone = -> h.postInProgress = false
@h.flushPushedModels = (store) ->
  return unless h.pushedModels?.length
  if h.postInProgress
    setTimeout (-> h.flushPushedModels(store)), 50
    return
  Ember.schedule 'sync', ->
    for d in h.pushedModels
      [model, data] = d
      console.log 'qq', data
      store.pushPayload(model, data)
    h.pushedModels = []

@h.setupPusher = (store, model, key) ->
  manyHash = (d) ->
    h = {}
    h[model.pluralize()] = [d]
    return h

  c = pusher.subscribe(key)
  c.callbacks._callbacks = {}
  c.bind "#{model.toLowerCase()}#new", (o) ->
    console.log 'new', manyHash(o)
    # return if store.getById(model, o.id)
    h.pushedModels.push [model, manyHash(o)]
    h.flushPushedModels(store)

  c.bind "#{model.toLowerCase()}#update", (o) ->
    f = store.getById(model, o.id)
    return if +(new Date(f?.get('updated_at'))) > +(new Date(o.updated_at))
    h.pushedModels.push [model, manyHash(o)]
    h.flushPushedModels(store)
    # store.pushPayload(model, manyHash(o))

  c.bind "#{model.toLowerCase()}#delete", (o) ->
    Ember.run.next ->
      store.getById(model, o.id)?.deleteRecord()

  return c

Ember.Handlebars.helper 'round', (amount) ->
  return 0 unless amount
  h.n2f(amount).noExponents()

Ember.Handlebars.helper 'noExp', (amount) ->
  return 0 unless amount
  amount.noExponents()

Ember.Handlebars.helper 'orZero', (v) ->
  if v then return v else return 0

Ember.Handlebars.helper 'orEmpty', (v) ->
  if v then return v else return ''
