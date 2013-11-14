@h ||= {}

@h.f2n = (f) -> Math.round(f * Math.pow(10, 8))
@h.n2f = (n) -> n / Math.pow(10,8)
@h.nn2n = (n) -> Math.round(n / Math.pow(10,8))
@h.nn2f = (n) -> n / Math.pow(10,16)

@h.round = (amount, precision = 8) ->
  amount * Math.pow(10, precision) / Math.pow(10, precision)

@h.openLoginMenu = -> $('#login-menu-link').dropdown('toggle')

@h.setupPusher = (store, model, key) ->
  manyHash = (d) ->
    h = {}
    h[model.pluralize()] = [d]
    return h

  c = pusher.subscribe(key)
  c.callbacks._callbacks = {}
  c.bind "#{model.toLowerCase()}#new", (o) ->
    return if store.getById(model, o.id)
    store.pushPayload(model, manyHash(o))

  c.bind "#{model.toLowerCase()}#update", (o) ->
    if f = store.getById(model, o.id)
      return if new Date(f?.get('updated_at')) > new Date(o.updated_at)
      store.pushPayload(model, manyHash(o))
    else
      store.pushPayload(model, manyHash(o))

  c.bind "#{model.toLowerCase()}#delete", (o) ->
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
