# For more information see: http://emberjs.com/guides/routing/

Cx.Router.map () ->
  @route 'tradeIndex', {path: '/'}
  @resource 'changePassword', {path: '/account/change_password'}, ->
    @route 'token', {path: '/:token'}
  @route 'tradePair', {path: '/trade/:url_slug'}
  @route 'balances', {path: '/account/balances'}
  @route 'balanceChanges', {path: '/account/balances/:name/details'}
  # @route 'catchAll', {path: '*:'}

Cx.CatchAllRoute = Em.Route.extend
  redirect: -> @transitionTo('tradeIndex')

Cx.Router.reopen
  location: 'history'
