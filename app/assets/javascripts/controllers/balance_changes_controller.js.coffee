Cx.BalanceHistoryController = Ember.Controller.extend
  ctrl: Ember.ArrayController.create
    sortProperties: ['num_id']
    sortAscending: false
  sortedItems: (->
    @get('ctrl').set('content', @get('content'))
    @get('ctrl.arrangedContent')
  ).property('content', 'content.@each')
