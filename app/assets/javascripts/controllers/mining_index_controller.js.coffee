Cx.MiningIndexController = Em.Controller.extend
  needs: ['currencies']
  sha256Currencies: Em.computed.alias('controllers.currencies.sha256')
  scryptCurrencies: Em.computed.alias('controllers.currencies.scrypt')
  sha256Hashrate: Em.computed.alias('controllers.currencies.sha256Hashrate')
  scryptHashrate: Em.computed.alias('controllers.currencies.scryptHashrate')

  actions:
    openStats: (curr) -> @transitionToRoute 'miningPool', curr
