Cx.RecentTradesComponent = Ember.Component.extend
  ctrl: Ember.ArrayController.create
    sortProperties: ['created_at']
    sortAscending: false
  sortedTrades: (->
    @ctrl.set('content', @get('trades'))
    @ctrl.get('arrangedContent')
  ).property('trades')
