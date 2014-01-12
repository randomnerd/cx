Cx.AccountSettingsController = Em.Controller.extend
  needs: ['auth']
  user: Em.computed.alias('controllers.auth.content')
  nameObserver: (->
    @set 'nickname', @get('user.nickname')
  ).observes('user.nickname').on('init')

  nameChanged: (->
    @get('nickname') != @get('user.nickname')
  ).property('user.nickname', 'nickname')

  verifyTOTP: (->
    totp = @get('totp')
    return unless totp.length == 6

    xhr = $.post "/api/v2/users/#{@get 'user.id'}/verify_totp", { totp: totp }
    @set 'totpProcessing', true
    xhr.done (data) =>
      @set 'totp', ''
      @set 'user.totp_active', data.user.totp_active
      @set 'user.totp_qr', data.user.totp_qr
      @set 'wrongTOTP', false
    xhr.fail => @set 'wrongTOTP', true
    xhr.always =>
      @set 'totpProcessing', false
      Em.run.schedule 'afterRender', ->
        $('#totp-input').select()
        $('#totp-input').focus()
  ).observes('totp')

  actions:
    setNickname: ->
      xhr = $.post "/api/v2/users/#{@get 'user.id'}/set_nickname", { name: @get('nickname') }
      xhr.done (data) =>
        h.ga_track('Chat', 'changeName', "#{@get('user.nickname')} (#{@get('user.email')}): #{data.user.nickname}")
        @set 'user.nickname', data.user.nickname

    revealApiSecret: ->
      xhr = $.post "/api/v2/users/#{@get 'user.id'}/get_api_secret", { password: @get('apiPassword') }
      @set('apiPassword', undefined)
      xhr.fail =>
        @set 'badPassword', true
        $('#api-password').focus()
      xhr.done (data) =>
        @set 'apiSecret', data.api_secret
        @set 'badPassword', undefined
        Em.run.next -> $('#api-secret').select()
        xhr.fail => @set 'badPassword', true

    hideApiSecret: -> @set 'apiSecret', undefined

    generateApiKeys: ->
      if @get 'currentUser.api_key'
        return unless confirm('This will invalidate your current API Key pair. Do you want to continue?')
      xhr = $.get "/api/v2/users/#{@get 'user.id'}/generate_api_keys"
      xhr.done (data) =>
        @set 'apiSecret', undefined
        @set 'currentUser.api_key', data.api_key
