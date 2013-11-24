Cx.ChangePasswordRoute = Em.Route.extend
  beforeModel: (route) ->
    if !@controllerFor('auth').get('isSignedIn') && !route.params.token
      @transitionTo('tradeIndex')

Cx.ChangePasswordTokenRoute = Em.Route.extend
  model: (params) -> params
  setupController: (c, params) ->
    @controllerFor('changePassword').set 'token', params.token
