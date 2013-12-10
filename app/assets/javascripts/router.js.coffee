# For more information see: http://emberjs.com/guides/routing/

Cx.Router.map () ->
  @route 'tradeIndex', {path: '/'}
  @resource 'changePassword', {path: '/account/change_password'}, ->
    @route 'token', {path: '/:token'}
  @route 'tradePair', {path: '/trade/:url_slug'}
  @route 'balances', {path: '/account/balances'}
  @route 'accountSettings', {path: '/account/settings'}
  @route 'balanceChanges', {path: '/account/balances/:name/details'}
  @route 'miningIndex', {path: '/mining/pools'}
  @route 'miningPool', {path: '/mining/pools/:name'}
  @route 'workers', {path: '/account/workers'}
  # @route 'catchAll', {path: '*:'}

Cx.CatchAllRoute = Em.Route.extend
  redirect: -> @transitionTo('tradeIndex')

Cx.Router.reopen
  location: 'history'
