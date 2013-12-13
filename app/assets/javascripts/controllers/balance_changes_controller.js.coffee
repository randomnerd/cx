Cx.BalanceChangesController = Em.ArrayController.extend InfiniteScroll.ControllerMixin,
  perPage: 10
  sortProperties: ['num_id']
  sortAscending: false
  needs: ['auth', 'deposits']
  deposits: Em.computed.alias('controllers.deposits.unprocessed')
  filteredDeposits: (->
    @get('deposits').filter (o) => @filter(o)
  ).property('deposits.@each')
  setupPusher: (->
    return unless uid = @get 'controllers.auth.id'
    @channel?.unsubscribe()
    @channel = h.setupPusher @store, 'balanceChange', "private-balanceChanges-#{uid}", @
  ).on('init').observes('controllers.auth.id')
  filter: (o) ->
    o.get('currency.id') == @get('currency.id')
  setFilter: (->
    @set 'model', @store.filter 'balanceChange', (o) => @filter(o)
  ).on('init').observes('currency.id')
  addObject: (o) ->
    return unless @filter(o)
    @_super(o)

Cx.BalanceChangesView = Em.View.extend InfiniteScroll.ViewMixin,
  didInsertElement: -> @setupInfiniteScrollListener()
  willDestroyElement: -> @teardownInfiniteScrollListener()
