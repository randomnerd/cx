# For more information see: http://emberjs.com/guides/routing/

Cx.Router.map () ->
  @route 'tradeIndex', {path: '/'}
  @route 'tradePair', {path: '/trade/:url_slug'}
  @route 'balances', {path: '/account/balances'}
  @route 'balanceHistory', {path: '/account/balances/:name/history'}

# Cx.Router.reopen
#   location: 'history'
