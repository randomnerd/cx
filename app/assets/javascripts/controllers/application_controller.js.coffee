# Cx.ApplicationController = Ember.Controller.extend
#   needs: ['auth']
#   user: (->
#     @get 'controllers.auth.content'
#   ).property('controllers.auth.content')
#   tradePairs: (-> @store.findAll('tradePair') ).property()
#   currencies: (-> @store.findAll('currency') ).property()
#   balances: (->
#     @store.findAll('balance')
#     @store.filter 'balance', (o) -> o.get('user.id') == @get('user.id')
#   ).property('user.id')
#   notifications: (->
#     @store.findAll('notification')
#     @store.filter 'notification', (o) -> o.get('user.id') == @get('user.id')
#   ).property('user.id')
