Cx.CommonChatController = Ember.ArrayController.extend
  sortProperties: ['createdAt']
  sortAscending: true
  hide: true
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
    setTimeout (=>
      return if @lock
      c.scrollTop c[0]?.scrollHeight
    ), 50
  ).observes('content.@each.body')

  init: ->
    setTimeout (=>
      $('#chat .messages').on 'scroll', (e) =>
        el = e.currentTarget
        @lock = el.scrollTop + $(el).height() * 1.5 < el.scrollHeight
    ), 50


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
