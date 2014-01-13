Cx.CurrencyController = Em.ObjectController.extend
  needs: ['auth', 'currencies', 'balances']
  balances: Em.computed.alias('controllers.balances')
  currencies: Em.computed.alias('controllers.currencies')
  balance: (->
    scope = @get('balances.content').filter (o) => o.get('currency.id') == @get('id')
    scope.get('firstObject')
  ).property('balances.@each')
  samealgo_currencies: (->
    @get('currencies.content').filter (o) => o.get('algo') == @get('algo')
  ).property('currencies.@each')
  top_mining_score: (->
    samealgo = @get('samealgo_currencies')
    sorted = _.sortBy(samealgo, (o) -> o.get('mining_score'))
    sorted.reverse()[0]?.get('id') == @get('id')
  ).property('samealgo_currencies.@each')
