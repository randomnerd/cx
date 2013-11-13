Cx.Notification = DS.Model.extend
  user: DS.belongsTo('user')
  title: DS.attr('string')
  body: DS.attr('string')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  ack: DS.attr('boolean')
  time: (->
    d = new Date(@get('created_at'))
    d.toISOString()
  ).property('created_at')
