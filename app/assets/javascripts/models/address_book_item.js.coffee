Cx.AddressBookItem = DS.Model.extend
  name: DS.attr('string')
  address: DS.attr('string')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  user: DS.belongsTo('user')
  currency: DS.belongsTo('currency')
