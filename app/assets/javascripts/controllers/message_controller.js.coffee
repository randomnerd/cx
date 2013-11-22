Cx.MessageController = Em.Controller.extend
  needs: ['auth']
  mention: (->
    nick = @get('controllers.auth.nickname')
    return false unless nick
    !!@get('content.body').match(nick)
  ).property('content.body', 'controllers.auth.nickname')
  own: (->
    @get('content.name') == @get('controllers.auth.nickname')
  ).property('content.body', 'controllers.auth.nickname')

  actions:
    remove: (msg) ->
      msg.deleteRecord()
      msg.save()
