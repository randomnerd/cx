Cx.TradeController = Em.ObjectController.extend
  needs: ['auth']
  user: Em.computed.alias('controllers.auth')
  bid: (->
    if @get('bid_user_id') == parseInt(@get('user.id')) || @get('ask_user_id') == parseInt(@get('user.id'))
       @get('bid_user_id') == parseInt(@get('user.id'))
    else
      @get('content.bid')
  ).property('content.bid', 'content.bid_user_id')
