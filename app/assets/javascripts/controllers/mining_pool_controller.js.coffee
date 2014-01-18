Cx.MiningPoolController = Em.Controller.extend
  needs: ['blocks', 'hashrates', 'currencies']
  blocks: Em.computed.alias('controllers.blocks')
  hashrates: Em.computed.alias('controllers.hashrates')
  topScrypt: Em.computed.alias('controllers.currencies.top_mining_coin_scrypt')
  topSha256: Em.computed.alias('controllers.currencies.top_mining_coin_sha256')
  currentCoin: (->
    switch @get('currency.algo')
      when 'scrypt' then @get('topScrypt')
      when 'sha256' then @get('topSha256')
  ).property('currency')
