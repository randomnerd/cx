Cx.CurrenciesController = Em.ArrayController.extend
  sortProperties: ['name']
  setupPusher: (->
    h.setupPusher @store, 'currency', 'currencies'
  ).on('init')

  scrypt: (->
    @store.filter 'currency', (o) -> o.get('algo') == 'scrypt'
  ).property()

  sha256: (->
    @store.filter 'currency', (o) -> o.get('algo') == 'sha256'
  ).property()

  scryptHashrate: (->
    hrate = 0
    @get('scrypt').forEach (c) -> hrate += c.get('hashrate') || 0
    hrate
  ).property('scrypt.@each.hashrate')

  sha256Hashrate: (->
    hrate = 0
    @get('sha256').forEach (c) -> hrate += c.get('hashrate') || 0
    hrate
  ).property('sha256.@each.hashrate')
