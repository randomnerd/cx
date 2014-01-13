Cx.TimeagoView = Ember.View.extend
  tagName: 'small'
  classNames: ['timeago']
  attributeBindings: ['title', 'name', 'class']
  didInsertElement: ->
    Ember.run.schedule 'afterRender', => @.$()?.timeago()

  titleObserver: (->
    @.$()?.timeago('update', @get('title'))
  ).observes('title')
