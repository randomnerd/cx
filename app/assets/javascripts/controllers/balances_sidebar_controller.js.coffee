Cx.BalancesSidebarController = Em.Controller.extend
  needs: ['auth']
  user: (-> @get 'controllers.auth').property('controllers.auth.content')
  balances: (->
    return unless @get('user.id')
    @store.findAll('balance')
    @store.filter 'balance', (b) =>
      b.get('user.id') == @get('user.id')
  ).property('user.id')
