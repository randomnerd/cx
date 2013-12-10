Cx.MiningIndexController = Em.Controller.extend
  needs: ['currencies']
  sha256Currencies: Em.computed.alias('controllers.currencies.sha256')
  scryptCurrencies: Em.computed.alias('controllers.currencies.scrypt')

  actions:
    openStats: (curr) -> @transitionToRoute 'miningPool', curr
