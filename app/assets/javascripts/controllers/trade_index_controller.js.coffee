Cx.TradeIndexController = Em.Controller.extend
  needs: ['tradePairs']
  actions:
    openPair: (pair) -> @transitionTo 'tradePair', pair
