## In a real app you will probably want to separate components into different files
## They are grouped together here for ease of exposition

Cx.AuthController = Ember.ObjectController.extend
  needs: ['commonLoginBox', 'commonFlashMessages']
  isSignedIn: Em.computed.notEmpty("content.email")
  workerStats: (->
    @store.filter 'workerStat', -> true
  ).property()
  hashrate: (->
    hrate = 0
    @get('workerStats').forEach (s) ->
      hrate += s.get('hashrate') || 0
    hrate
  ).property('workerStats.@each.hashrate')
  attemptedTransition: null
  login: (r) ->
    $.ajax
      url: '/users/sign_in'
      type: "POST"
      data:
        "authenticity_token": $('meta[name=csrf-token]').attr('content')
        "user[email]": $('#login-email').val()
        "user[password]": $('#login-password').val()
      success: (data) =>
        $('meta[name="csrf-token"]').attr('content', data.token)
        object = @store.push(Cx.User, data.user)
        user = @store.find(Cx.User, object.id)
        @set 'model', user
        @get('controllers.commonLoginBox').set "loginErrorMsg", null
        @target.send('loadUserData', user)
        if attemptedTrans = @get 'attemptedTransition'
          attemptedTrans.retry()
          @set 'attemptedTransition', null
      error: (jqXHR, textStatus, errorThrown) =>
        @get('controllers.commonLoginBox').set "loginErrorMsg", "Incorrect email/password"

  forgotPassword: (email) ->
    $.ajax
      url: '/users/password'
      type: "POST"
      data:
        "user[email]": $('#login-email').val()
      success: (data) =>
        @get('controllers.commonLoginBox').set "loginInfoMsg", "Recovery email sent"

  changePasswordWithToken: (c) ->
    $.ajax
      url: '/users/password'
      type: "PUT"
      data:
        "user[password]": c.get('newPassword')
        "user[password_confirmation]": c.get('newPassword')
        "user[reset_password_token]": c.get('token')
      success: (data) =>
        $('meta[name="csrf-token"]').attr('content', data.token)
        object = @store.push(Cx.User, data.user)
        user = @store.find(Cx.User, object.id)
        @set 'model', user
        @target.transitionTo('tradeIndex')
        location.reload()

      error: (data) =>
        flash = @get('controllers.commonFlashMessages')
        for key, value of data.responseJSON?.errors
          flash.add_alert { message: [key, value].join(' ') }

  changePassword: (c) ->
    $.ajax
      url: '/users'
      type: "PUT"
      data:
        "user[password]": c.get('newPassword')
        "user[password_confirmation]": c.get('newPassword')
        "user[current_password]": c.get('oldPassword')
      success: (data) =>
        c.set 'oldPassword', ''
        c.set 'newPassword', ''
        c.set 'newPasswordConf', ''
        @target.transitionTo('tradeIndex')

  register: (r) ->
    $.ajax
      url: '/users'
      type: "POST"
      data:
        "user[email]": $('#login-email').val()
        "user[password]": $('#login-password').val()
        "user[password_confirmation]": $('#login-password').val()
      success: (data) =>
        $('meta[name="csrf-token"]').attr('content', data.token)
        @get('controllers.commonLoginBox').set "loginErrorMsg", null
        @get('controllers.commonLoginBox').set "loginInfoMsg", "Check your mailbox please."
        @get('controllers.commonLoginBox').set "regMode", false
      error: (jqXHR, textStatus, errorThrown) =>
        @get('controllers.commonLoginBox').set "loginErrorMsg", "Error registering, please try again"

  logout: ->
    $.ajax
      url: '/users/sign_out'
      type: "DELETE"
      dataType: "json"
      data:
        "authenticity_token": $('meta[name=csrf-token]').attr('content')
      success: (data, textStatus, jqXHR) => location.reload()
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error logging out: #{errorThrown}"
