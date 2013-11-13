Cx.User = DS.Model.extend
  email:    DS.attr('string')
  nickname: DS.attr('string')
  createdAt: DS.attr('date')
  notifications: DS.hasMany('notification', {async: true})
