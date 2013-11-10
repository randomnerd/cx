# Cx.TradePairController = Ember.Controller.extend
#   model: (params) ->
#     tps = @store.filter 'tradePair', (tp) ->
#       tp.get('urlSlug') == params.urlSlug
#     tps.get('firstObject')

#   orders: (->
#     @store.filter 'order', (o) =>
#       o.get('tradePair.id') == @get('id')
#   ).property()

#   ownOrders: (->
#     @store.filter 'order', (o) =>
#       o.get('tradePair.id') == @get('id') &&
#       o.get('user.id') == uid
#   ).property()
