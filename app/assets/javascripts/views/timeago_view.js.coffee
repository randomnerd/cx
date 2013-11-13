Cx.TimeagoView = Ember.View.extend
  tagName: 'small'
  classNames: ['timeago']
  attributeBindings: ['title', 'name', 'class']
  didInsertElement: -> setTimeout (=>@.$()?.timeago()), 50
