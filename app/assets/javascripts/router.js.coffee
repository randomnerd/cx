# For more information see: http://emberjs.com/guides/routing/

Cx.Router.map () ->
  @route 'tradeIndex', {path: '/'}
  @route 'tradePair', {path: '/trade/:url_slug'}
  @route 'balances', {path: '/account/balances'}
  @route 'balanceChanges', {path: '/account/balances/:name/details'}

Cx.Router.reopen
  location: 'history'
