Cx.ChangePasswordController = Em.Controller.extend
  user: Em.computed.alias('controllers.auth')
  needs: ['auth']
  allowSave: (->
    return if !@get('token') && !@get('oldPassword')
    return unless @get('newPassword') && @get('newPasswordConf')
    return unless @get('newPassword') == @get('newPasswordConf')
    true
  ).property('oldPassword', 'newPassword', 'newPasswordConf')
  focusFirstInput: (->
    Ember.run.schedule 'afterRender', -> $('#change-password-form input')[0].focus()
  ).on('init')
  actions:
    submit: ->
      if @get('token')
        @get("controllers.auth").changePasswordWithToken(@)
      else
        @get("controllers.auth").changePassword(@)

