Cx.RecentTradesComponent = Ember.Component.extend
  ctrl: Ember.ArrayController.create
    sortProperties: ['created_at']
    sortAscending: false
  proxy: Ember.ArrayProxy.create()
  sortedTrades: (->
    @ctrl.set('content', @get('trades'))
    @proxy.set('content', @ctrl.get('arrangedContent'))
    @proxy
  ).property('trades')
