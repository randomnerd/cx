Cx.CommonChatController = Ember.ArrayController.extend
  sortProperties: ['created_at']
  sortAscending: true
  lock: false
  hide: false
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
    setTimeout (=>
      c.scrollTop c[0]?.scrollHeight
    ), 100
  ).observes('content.@each')

  init: ->
    Ember.run.later =>
      $('#chat .messages').on 'scroll', (e) =>
        el = e.currentTarget
        @lock = el.scrollTop + $(el).height() * 1.1 < el.scrollHeight

    @channel = pusher.subscribe('messages')
    @channel.bind 'message#new', (message) =>
      found = @store.getById('message', message.id)
      unless found
        @store.pushPayload 'message', messages: [message]

  actions:
    toggle: -> @set 'hide', !@get 'hide'
    submit: ->
      return unless @get('msg')
      message = @store.createRecord 'message',
        name: @get('user.nickname')
        body: @get('msg')
        createdAt: new Date()
      message.save()

      @set 'msg', ''
