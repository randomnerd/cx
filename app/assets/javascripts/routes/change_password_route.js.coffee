Cx.ChangePasswordRoute = Em.Route.extend
  beforeModel: (route) ->
    if @controllerFor('auth').get('isSignedIn')
      @transitionTo('tradeIndex') if route.params['changePassword.token']
    else
      @transitionTo('tradeIndex') unless route.params['changePassword.token']

Cx.ChangePasswordTokenRoute = Em.Route.extend
  model: (params) -> params
  setupController: (c, params) ->
    @controllerFor('changePassword').set 'token', params.token
