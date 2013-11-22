Cx.CommonChatController = Ember.ArrayController.extend
  lock: false
  msg: ''
  needs: ['auth', 'messages']

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
    console.log 'mentioned', this
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
        name: @get('controllers.auth.nickname')
        body: @get('msg')
        created_at: new Date()
      message.save()
      @set 'msg', ''
      Ember.run.next -> $('#chat input').focus()
    addName: (item) ->
      msg = @get 'msg'
      @set 'msg', "#{msg}#{item.get('name')}, "
      Ember.run.next -> $('#chat input').focus()
