Cx.CurrenciesController = Em.ArrayController.extend
  sortProperties: ['name']
  setupPusher: (->
    h.setupPusher @store, 'currency', 'currencies'
  ).on('init')

  nonVirtual: (->
    @filter (o) -> o.get('virtual') == false
  ).property('@each', '@each.virtual')

  virtual: (->
    @filter (o) -> o.get('virtual')
  ).property('@each', '@each.virtual')

  scrypt: (->
    a = @get('nonVirtual').filter (o) -> o.get('algo') == 'scrypt'
    h.sortedArray(a, ['name'], true)
  ).property('nonVirtual.@each')

  sha256: (->
    a = @get('nonVirtual').filter (o) -> o.get('algo') == 'sha256'
    h.sortedArray(a, ['name'], true)
  ).property('nonVirtual.@each')

  switchPools: (->
    @get('virtual').filter (o) -> !!o.get('name')?.match('SwitchPool')
  ).property('virtual.@each', 'virtual.@each.name')

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

  top_mining_coin: (algo) ->
    currs  = @get(algo).filter (o) -> o.get('mining_skip_switch') == false
    sorted = _.sortBy(currs, (o) -> o.get('mining_score'))
    sorted.reverse()[0]

  top_mining_coin_scrypt: (->
    @top_mining_coin('scrypt')
  ).property(
    'scrypt.@each',
    'scrypt.@each.mining_score',
    'scrypt.@each.mining_skip_switch'
  )

  top_mining_coin_sha256: (->
    @top_mining_coin('sha256')
  ).property(
    'sha256.@each',
    'sha256.@each.mining_score',
    'sha256.@each.mining_skip_switch'
  )
