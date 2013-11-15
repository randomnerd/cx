Cx.CommonChatController = Ember.ArrayController.extend
  sortProperties: ['created_at']
  sortAscending: true
  lock: false
  msg: ''
  needs: ['auth']
  signedIn: (->
    @get('controllers.auth.isSignedIn')
  ).property('controllers.auth.isSignedIn')
  user: (->
    @get('controllers.auth.content.content')
  ).property('controllers.auth.content.content')

  scroller: (->
    c = $('#chat .messages')
    return if @lock
    Ember.run.schedule 'afterRender', ->
      c.scrollTop c[0]?.scrollHeight
  ).observes('content.@each')
  allowSend: (->
    !!@get('msg')
  ).property('msg')

  init: ->
    @set 'hide', $.cookie('hideChat') == 'true'
    Ember.run.later =>
      $('#chat .messages').on 'scroll', (e) =>
        el = e.currentTarget
        @lock = el.scrollTop + $(el).height() * 1.1 < el.scrollHeight

  actions:
    toggle: ->
      hide = !@get 'hide'
      $.cookie('hideChat', hide)
      @set 'hide', hide
    submit: ->
      return unless @get('allowSend')
      @lock = false
      message = @store.createRecord 'message',
        name: @get('user.nickname')
        body: @get('msg')
        created_at: new Date()
      message.save()
      @set 'msg', ''
      Ember.run.next -> $('#chat input').focus()
