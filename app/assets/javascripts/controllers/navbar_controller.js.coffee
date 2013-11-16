Cx.CommonNavbarController = Ember.Controller.extend
  needs: ['auth']
  actions:
    login: -> @get("controllers.auth").login(@)
    logout: -> @get("controllers.auth").logout(@)
