Cx.AuthRoute = Ember.Route.extend
  beforeModel: (transition) ->
    unless @controllerFor('auth').get('isSignedIn')
      @redirectToHome(transition)

  redirectToHome: (transition) ->
    @controllerFor('auth').set('attemptedTransition', transition)
    @transitionTo('tradeIndex')

  actions:
    error: (reason, transition) -> @redirectToHome(transition)
