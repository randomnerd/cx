Cx.HashrateController = Em.ObjectController.extend
  needs: ['auth']
  user: Em.computed.alias('controllers.auth.content')
  own: (->
    @get('name') == @get('user.nickname')
  ).property('user.nickname', 'name')
