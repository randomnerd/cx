Cx.MessageController = Em.ObjectController.extend
  needs: ['auth']
  mention: (->
    nick = @get('controllers.auth.nickname')
    return false unless nick
    !!@get('body').match(nick)
  ).property('body', 'controllers.auth.nickname')
  own: (->
    @get('name') == @get('controllers.auth.nickname')
  ).property('body', 'controllers.auth.nickname')

  actions:
    remove: (msg) ->
      msg.deleteRecord()
      msg.save()
