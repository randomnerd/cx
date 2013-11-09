Cx.BalancesSidebarController = Em.Controller.extend
  needs: ['application']
  balances: (->
    @get('controllers.application.balances')
  ).property('controllers.application.balances')
