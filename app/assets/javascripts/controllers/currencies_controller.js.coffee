Cx.CurrenciesController = Em.ArrayController.extend
  sortProperties: ['name']
  setupPusher: (->
    h.setupPusher @store, 'currency', 'currencies'
  ).on('init')

  public: (->
    @filter (o) -> o.get('public')
  ).property('@each', '@each.public')

  scrypt: (->
    a = @get('public').filter (o) -> o.get('algo') == 'scrypt'
    h.sortedArray(a, ['name'], true)
  ).property('public')

  sha256: (->
    a = @get('public').filter (o) -> o.get('algo') == 'sha256'
    h.sortedArray(a, ['name'], true)
  ).property('public')

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
