@h ||= {}

@h.f2n = (f) -> Math.round(f * Math.pow(10, 8))
@h.n2f = (n) -> n / Math.pow(10,8)
@h.nn2n = (n) -> Math.round(n / Math.pow(10,8))
@h.nn2f = (n) -> n / Math.pow(10,16)

@h.round = (amount, precision = 8) ->
  Math.round(amount * Math.pow(10, precision)) / Math.pow(10, precision)

@h.openLoginMenu = -> $('#login-menu-link').dropdown('toggle')

@h.manyHash = (model, d) ->
  h = {}
  h[model.pluralize()] = [d]
  return h

@h.sortedArray = (data, sortP, sortA) ->
  Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
    content: data
    sortProperties: sortP
    sortAscending: sortA

@h.setupPusher = (store, model, key, ctrl, updPush = true) ->
  c = pusher.subscribe(key)
  c.callbacks._callbacks = {}
  c.bind "c", (o) ->
    return if store.getById(model, o.id)
    console.log 'new', model, o.id
    store.pushPayload(model, h.manyHash(model, o))
    obj = store.getById(model, o.id)
    ctrl?.addObject(obj)

  c.bind "u", (o) ->
    f = store.getById(model, o.id)
    return if f && +(new Date(f?.get('updated_at'))) > +(new Date(o.updated_at))
    return if !f && !updPush
    console.log 'upd', model, o.id
    store.pushPayload(model, h.manyHash(model, o))

  c.bind "uu", (o) ->
    f = store.getById(model, o.id)
    return unless f
    for key, value of o.fields
      console.log key, value
      if key == 'created_at' || key == 'updated_at' || key == 'last_block_at'
        f.set key, new Date(value)
      else
        f.set key, value

  c.bind "d", (o) ->
    Ember.run.next ->
      obj = store.getById(model, o.id)
      return unless obj
      ctrl?.removeObject(obj)
      obj.deleteRecord()

  return c

@h.hrate = (hashrate, na = true) ->
  unless hashrate
    if na
      return new Handlebars.SafeString('<span class="text-muted">N/A</span>')
    else return ''
  if hashrate > 1000000
    h.round(hashrate / 1000000, 2) + " Th/s"
  else if hashrate > 1000
    h.round(hashrate / 1000, 2) + " Gh/s"
  else if hashrate < 1
    h.round(hashrate * 1000, 2) + " Kh/s"
  else
    h.round(hashrate, 2) + " Mh/s"

Ember.Handlebars.helper 'round', (amount) ->
  return 0 unless amount
  h.round(h.n2f(amount)).noExponents()

Ember.Handlebars.helper 'noExp', (amount) ->
  return 0 unless amount
  h.round(amount).noExponents()

Ember.Handlebars.helper 'orZero', (v) ->
  if v then return v else return 0

Ember.Handlebars.helper 'orEmpty', (v) ->
  if v then return v else return ''

Ember.Handlebars.helper 'hrate', (rate, na = true) -> h.hrate(rate / 1000, na)

@h.addCommas = (nStr) ->
  nStr += ''
  x = nStr.split('.')
  x1 = x[0]
  x2 = if x.length > 1 then '.' + x[1] else ''
  rgx = /(\d+)(\d{3})/
  while rgx.test(x1)
    x1 = x1.replace(rgx, '$1' + ',' + '$2')
  return x1 + x2
Handlebars.registerHelper 'addCommas', (num) -> h.addCommas num
