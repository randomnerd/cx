Cx.Hashrate = DS.Model.extend
  rate:         DS.attr('number')
  name:         DS.attr('string')
  user_id:      DS.attr('number')
  currency:     DS.belongsTo('currency')
  switchpool:   DS.attr('boolean')
