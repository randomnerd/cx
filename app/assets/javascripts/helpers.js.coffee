@h ||= {}

@h.f2n = (f) -> Math.round(f * Math.pow(10, 8))
@h.n2f = (n) -> n / Math.pow(10,8)
@h.nn2n = (n) -> Math.round(n / Math.pow(10,8))
@h.nn2f = (n) -> n / Math.pow(10,16)

@h.round = (amount, precision = 8) ->
  Math.round(amount * Math.pow(10, precision)) / Math.pow(10, precision)

@h.openLoginMenu = -> $('#login-menu-link').dropdown('toggle')
@h.postInProgress ||= false
@h.pushedModels ||= []
@h.postDone = -> h.postInProgress = false
@h.flushPushedModels = (store) ->
  return unless h.pushedModels?.length
  if h.postInProgress
    setTimeout (-> h.flushPushedModels(store)), 50
    return
  Ember.run.schedule 'sync', ->
    for d in h.pushedModels
      [model, data] = d
      continue if store.getById(model, data.id)
      store.pushPayload(model, h.manyHash(model, data))
    h.pushedModels = []

@h.manyHash = (model, d) ->
  h = {}
  h[model.pluralize()] = [d]
  return h

@h.sortedArray = (data, sortP, sortA) ->
  Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
    content: data
    sortProperties: sortP
    sortAscending: sortA

@h.setupPusher = (store, model, key, ctrl) ->
  c = pusher.subscribe(key)
  c.callbacks._callbacks = {}
  c.bind "c", (o) ->
    return if store.getById(model, o.id)
    store.pushPayload(model, h.manyHash(model, o))
    obj = store.getById(model, o.id)
    ctrl?.addObject(obj)

  c.bind "u", (o) ->
    f = store.getById(model, o.id)
    return if f && +(new Date(f?.get('updated_at'))) > +(new Date(o.updated_at))
    store.pushPayload(model, h.manyHash(model, o))

  c.bind "d", (o) ->
    Ember.run.next ->
      obj = store.getById(model, o.id)
      return unless obj
      ctrl?.removeObject(obj)
      obj.deleteRecord()

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
