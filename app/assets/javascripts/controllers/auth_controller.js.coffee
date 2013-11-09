## In a real app you will probably want to separate components into different files
## They are grouped together here for ease of exposition

Cx.AuthController = Ember.ObjectController.extend
  isSignedIn: Em.computed.notEmpty("content.email")
  model: null
  content: null
  login: (route) ->
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
        @set 'content', user
        @set 'model', user
      error: (jqXHR, textStatus, errorThrown) ->
        if jqXHR.status==401
          route.controllerFor('login').set "errorMsg", "That email/password combo didn't work.  Please try again"
        else if jqXHR.status==406
          route.controllerFor('login').set "errorMsg", "Request not acceptable (406):  make sure Devise responds to JSON."
        else
          p "Login Error: #{jqXHR.status} | #{errorThrown}"

  register: (route) -> # FIXME
    $.ajax
      url: Cx.urls.register
      type: "POST"
      data:
        "user[name]": route.currentModel.name
        "user[email]": route.currentModel.email
        "user[password]": route.currentModel.password
        "user[password_confirmation]": route.currentModel.password_confirmation
      success: (data) =>
        @set 'currentUser', data.user
        route.transitionTo 'home'
      error: (jqXHR, textStatus, errorThrown) ->
        route.controllerFor('registration').set "errorMsg", "That email/password combo didn't work.  Please try again"

  logout: ->
    $.ajax
      url: '/users/sign_out'
      type: "DELETE"
      dataType: "json"
      data:
        "authenticity_token": $('meta[name=csrf-token]').attr('content')
      success: (data, textStatus, jqXHR) =>
        $('meta[name="csrf-token"]').attr('content', data['csrf-token'])
        $('meta[name="csrf-param"]').attr('content', data['csrf-param'])
        @set 'content', null
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error logging out: #{errorThrown}"
