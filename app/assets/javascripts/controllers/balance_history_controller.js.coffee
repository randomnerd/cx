Cx.BalanceHistoryController = Em.ArrayController.extend
  sortProperties: ['num_id']
  sortAscending: false
  sortedItems: (->
    @get('ctrl').set('content', @get('content'))
    @get('ctrl.arrangedContent')
  ).property('content', 'content.@each')
