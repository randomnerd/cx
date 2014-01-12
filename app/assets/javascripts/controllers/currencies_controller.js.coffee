Cx.CurrenciesController = Em.ArrayController.extend
  sortProperties: ['name']
  setupPusher: (->
    h.setupPusher @store, 'currency', 'currencies'
  ).on('init')

  scrypt: (->
    a = @filter (o) -> o.get('algo') == 'scrypt'
    h.sortedArray(a, ['name'], true)
  ).property('@each')

  sha256: (->
    a = @filter (o) -> o.get('algo') == 'sha256'
    h.sortedArray(a, ['name'], true)
  ).property('@each')

  scryptHashrate: (->
    hrate = 0
    @get('scrypt').forEach (c) -> hrate += parseInt(c.get('hashrate')) || 0
    hrate
  ).property('scrypt.@each.hashrate')

  sha256Hashrate: (->
    hrate = 0
    @get('sha256').forEach (c) -> hrate += parseInt(c.get('hashrate')) || 0
    hrate
  ).property('sha256.@each.hashrate')
