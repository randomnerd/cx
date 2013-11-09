Cx.CurrentUserController = Ember.ObjectController.extend
  isSignedIn: (->
    !!@get('content')
  ).property('@content')
