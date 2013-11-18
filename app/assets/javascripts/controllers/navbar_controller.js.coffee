Cx.CommonNavbarController = Ember.Controller.extend
  needs: ['auth', 'notifications']
  actions:
    login: -> @get("controllers.auth").login(@)
    logout: -> @get("controllers.auth").logout(@)
