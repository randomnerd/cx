Cx.TradeIndexController = Em.Controller.extend
  needs: ['tradePairs']
  actions:
    openPair: (pair) -> @transitionToRoute 'tradePair', pair
