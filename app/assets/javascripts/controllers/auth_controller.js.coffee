## In a real app you will probably want to separate components into different files
## They are grouped together here for ease of exposition

Cx.AuthController = Ember.ObjectController.extend
  needs: ['commonLoginBox']
  isSignedIn: Em.computed.notEmpty("content.email")
  model: null
  content: null
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
        @set 'content', user
        @set 'model', user
        @get('controllers.commonLoginBox').set "loginErrorMsg", null
      error: (jqXHR, textStatus, errorThrown) =>
        @get('controllers.commonLoginBox').set "loginErrorMsg", "Incorrect email/password"

  register: (r) -> # FIXME
    $.ajax
      url: '/users'
      type: "POST"
      data:
        "user[email]": @get('controllers.commonLoginBox.email')
        "user[password]": @get('controllers.commonLoginBox.password')
        "user[password_confirmation]": @get('controllers.commonLoginBox.password')
      success: (data) =>
        $('meta[name="csrf-token"]').attr('content', data.token)
        object = @store.push(Cx.User, data.user)
        user = @store.find(Cx.User, object.id)
        @set 'content', user
        @set 'model', user
        @get('controllers.commonLoginBox').set "loginErrorMsg", null
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
      success: (data, textStatus, jqXHR) =>
        $('meta[name="csrf-token"]').attr('content', data['csrf-token'])
        $('meta[name="csrf-param"]').attr('content', data['csrf-param'])
        @set 'content', null
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error logging out: #{errorThrown}"
