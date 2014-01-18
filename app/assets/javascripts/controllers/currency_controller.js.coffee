Cx.CurrencyController = Em.ObjectController.extend
  needs: ['auth', 'currencies', 'balances']
  balances: Em.computed.alias('controllers.balances')
  topSha: Em.computed.alias('controllers.currencies.top_mining_coin_sha256')
  topScrypt: Em.computed.alias('controllers.currencies.top_mining_coin_scrypt')
  balance: (->
    scope = @get('balances.content').filter (o) => o.get('currency.id') == @get('id')
    scope.get('firstObject')
  ).property('balances.@each')
  top_mining_coin: (->
    if @get('algo') == 'sha256' then @get('topSha') else @get('topScrypt')
  ).property('topSha', 'topScrypt', 'algo')
  top_mining_score: (->
    if @get('algo') == 'sha256'
      @get('topSha.id') == @get('id')
    else
      @get('topScrypt.id') == @get('id')
  ).property('top_mining_coin', 'algo')
