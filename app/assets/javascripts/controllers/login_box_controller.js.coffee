Cx.CommonLoginBoxController = Ember.Controller.extend
  needs: ['auth']
  actions:
    toggleRegMode: -> @set 'regMode', !@get('regMode')
    submitReg: ->
      console.log @get('email'), @get('password')
      @get("controllers.auth").register(@)

