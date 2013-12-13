Cx.CommonLoginBoxController = Ember.Controller.extend
  needs: ['auth']
  actions:
    toggleRegMode: -> @set 'regMode', !@get('regMode')
    toggleForgotMode: ->
      @set "loginInfoMsg", null
      @set 'forgotMode', !@get('forgotMode')
    submitReg: ->
      @get("controllers.auth").register(@)
    forgotPassword: ->
      @get("controllers.auth").forgotPassword(@get('email'))
