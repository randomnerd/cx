Cx.BlockPayout = DS.Model.extend
  amount:     DS.attr('number')
  user_id:    DS.attr('number')
  block:      DS.belongsTo('block')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  reward: (->
    block_reward = @get 'block.reward'
    amount       = @get 'amount'
    Math.round(block_reward * amount)
  ).property('block.reward', 'amount')
  fee: (->
    reward     = @get 'reward'
    mining_fee = @get 'block.currency.mining_fee'
    Math.round(reward / 100 * mining_fee)
  ).property('block.currency.mining_fee')
  reward_minus_fee: (->
    Math.round(@get('reward') - @get('fee'))
  ).property('reward', 'fee')
