Cx.User = DS.Model.extend
  email:    DS.attr('string')
  nickname: DS.attr('string')
  created_at: DS.attr('date')
  confirmed_at: DS.attr('date')
  notifications: DS.hasMany('notification', {async: true})
  confirmBefore: (->
    new Date(+new Date(@get('created_at')) + 3 * 24 * 3600 * 1000)
  ).property('created_at')
