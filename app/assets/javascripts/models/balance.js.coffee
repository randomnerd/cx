Cx.Balance = DS.Model.extend
  amount: DS.attr('number')
  held: DS.attr('number')
  user: DS.belongsTo('user')
  currency: DS.belongsTo('currency')
  updated_at: DS.attr('date')
  negative: (-> @get('amount') < 0 ).property('amount')
  allowWithdraw: (-> @get('amount') > 0.01 * Math.pow(10,8)).property('amount')

Cx.Balance.FIXTURES = [
  {
    id: 1
    user: 1
    currency: 3
    amount: 10
    held: 0
  }
  {
    id: 2
    user: 1
    currency: 2
    amount: 20
    held: 0
  }
  {
    id: 3
    user: 1
    currency: 1
    amount: 1
    held: 0
  }
]
