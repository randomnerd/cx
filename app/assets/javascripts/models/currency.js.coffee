Cx.Currency = DS.Model.extend
  name:            DS.attr('string')
  desc:            DS.attr('string')
  algo:            DS.attr('string')
  tx_fee:          DS.attr('number')
  tx_conf:         DS.attr('number')
  blk_conf:        DS.attr('number')
  public:          DS.attr('boolean')
  hashrate:        DS.attr('number')
  donations:       DS.attr('string')
  net_hashrate:    DS.attr('number')
  diff:            DS.attr('number')
  last_block_at:   DS.attr('date')
  mining_enabled:  DS.attr('boolean')
  mining_url:      DS.attr('string')
  mining_fee:      DS.attr('number')
  last_block_time: (-> @get('last_block_at')?.toISOString()).property('last_block_at')
  balance: (->
    @store.filter 'balance', (b) => b.get('currency.id') == @get('id')
  ).property()
  stats: (->
    @store.filter 'workerStat', (o) =>
      o.get('currency.id') == @get('id') &&
      +new Date(o.get('updated_at')) > +new Date() - 2 * 60 * 1000
  ).property()
  ownHashrate: (->
    hrate = 0
    @get('stats').forEach (s) ->
      hrate += s.get('hashrate') || 0
    hrate
  ).property('stats.@each')


Cx.Currency.FIXTURES = [
  {
    id: 1
    name: 'BTC'
    desc: 'Bitcoin'
    txFee: 0.0001
    txConf: 3
    blkConf: 120
    public: true
    hashrate: 123
    netHashrate: 123
    lastBlockAt: new Date()
    miningEnabled: true
    miningUrl: 'stratum+tcp://stratum.coinex.pw:9033'
    miningFee: 2
  }
  {
    id: 2
    name: 'LTC'
    desc: 'Litecoin'
    txFee: 0.01
    txConf: 6
    blkConf: 120
    public: true
    hashrate: 123
    netHashrate: 123
    lastBlockAt: new Date()
    miningEnabled: true
    miningUrl: 'stratum+tcp://stratum.coinex.pw:9034'
    miningFee: 2
  }
  {
    id: 3
    name: 'WDC'
    desc: 'Worldcoin'
    txFee: 0.1
    txConf: 6
    blkConf: 120
    public: true
    hashrate: 123
    netHashrate: 123
    lastBlockAt: new Date()
    miningEnabled: true
    miningUrl: 'stratum+tcp://stratum.coinex.pw:9034'
    miningFee: 2
  }
]

