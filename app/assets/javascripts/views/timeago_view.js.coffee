Cx.TimeagoView = Ember.View.extend
  tagName: 'small'
  classNames: ['timeago']
  attributeBindings: ['title', 'name']
  didInsertElement: -> setTimeout (=>@.$().timeago()), 50
