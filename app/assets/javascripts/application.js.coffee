#= require jquery
#= require jquery_ujs
#= require handlebars
#= require ember
#= require ember-data
#= require_self
#= require cx
#= require_tree .

# for more details see: http://emberjs.com/guides/application/
window.Cx = Ember.Application.create()

Ember.RSVP.configure 'onerror', (error) ->
  Ember.Logger.assert(false, error)

