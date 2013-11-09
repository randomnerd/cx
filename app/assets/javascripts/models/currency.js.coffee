Cx.Currency = DS.Model.extend
  name:           DS.attr('string')
  desc:           DS.attr('string')
  txFee:          DS.attr('number')
  txConf:         DS.attr('number')
  blkConf:        DS.attr('number')
  public:         DS.attr('boolean')
  hashrate:       DS.attr('number')
  netHashrate:    DS.attr('number')
  lastBlockAt:    DS.attr('date')
  miningEnabled:  DS.attr('boolean')
  miningUrl:      DS.attr('string')
  miningFee:      DS.attr('number')
  lastBlockAtISO: (-> @get('lastBlockAt')?.toISOString()).property('lastBlockAt')
  balance: (->
    proxy = Ember.ObjectProxy.create()
    @store.find('balance', {currency: @get('id')}).then (data) ->
      proxy.set('content', data.get('firstObject'))
    proxy
  ).property()

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

