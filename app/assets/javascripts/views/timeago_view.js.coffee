Cx.TimeagoView = Ember.View.extend
  tagName: 'small'
  classNames: ['timeago']
  attributeBindings: ['title', 'name', 'class']
  didInsertElement: ->
    unless @get 'title'
      @.$().html('<span class="text-muted">N/A</span>')
    Ember.run.schedule 'afterRender', => @.$()?.timeago()

  titleObserver: (->
    @.$()?.timeago('update', @get('title'))
  ).observes('title')
