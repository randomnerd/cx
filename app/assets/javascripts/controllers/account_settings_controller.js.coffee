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
      xhr.done (data) => @set 'user.nickname', data.user.nickname
