Cx.TradePairsSidebarController = Em.Controller.extend
  needs: ['application']
  tradePairs: (->
    @get('controllers.application.tradePairs')
  ).property('controllers.application.tradePairs')
