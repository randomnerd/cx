#= require jquery
#= require jquery_ujs
#= require handlebars
#= require ember
#= require ember-data
#= require ember-infinite-scroll
#= require google_analytics
#= require_self
#= require cx
#= require_tree .

# for more details see: http://emberjs.com/guides/application/
window.Cx = Ember.Application.create({rootElement: '#emberRoot'})

Ember.RSVP.configure 'onerror', (error) ->
  Ember.Logger.assert(false, error)

