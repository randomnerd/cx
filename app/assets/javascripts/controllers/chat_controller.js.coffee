Cx.CommonChatController = Ember.ArrayController.extend
  lock: false
  msg: ''
  needs: ['auth', 'messages']
  user: Em.computed.alias('controllers.auth')

  scroller: (->
    c = $('#chat .messages')
    return if @lock
    Ember.run.schedule 'afterRender', ->
      c.scrollTop c[0]?.scrollHeight
  ).observes('controllers.messages.@each')
  allowSend: (->
    !!@get('msg')
  ).property('msg')

  onInit: (->
    @set 'hide', $.cookie('hideChat') == 'true'
    Ember.run.later =>
      @scroller()
      $('#chat .messages').on 'scroll', (e) =>
        el = e.currentTarget
        @lock = el.scrollTop + $(el).height() * 1.1 < el.scrollHeight
  ).on('init')

  mentioned: ((a,b,c) ->
    !!a.match @get 'controllers.auth.nickname'
  ).property('controllers.auth.nickname')

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
      onSucc = =>
        h.ga_track('Chat', 'message', "#{@get('user.nickname')} (#{@get('user.email')}): #{@get('msg')}")
      onFail = (data) =>
        errors = []
        for key, value of data.errors
          errors.push msg for msg in value
        message.set('name', 'Message not sent')
        message.set('sErrors', errors)
        message.set('failed', true)

      message.save().then(onSucc, onFail)
      @set 'msg', ''
      Ember.run.next -> $('#chat input').focus()
    addName: (item) ->
      msg = @get 'msg'
      @set 'msg', "#{msg}#{item.get('name')}, "
      Ember.run.next -> $('#chat input').focus()
