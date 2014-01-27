class Pool::Sharelogger
  attr_accessor :server

  def initialize(pool)
    @server = pool
    @last_block_at = Time.now.utc
  end

  def log_share(share)
    share[:subscription].update_stats(share)
  end

  def log_block(share, block)
    log_share(share)
    server.log block.inspect
    server.on_block(share, block)
    save_block(share, block)
    server.reset_d1a
  rescue => e
    puts e.inspect
    puts e.backtrace
  end

  def save_block(share, block)
    b = server.currency.blocks.create(
      category: block['category'],
      algo: server.currency.algo,
      diff: block['difficulty'],
      txid: block['tx'][0],
      number: block['height'],
      reward: block['reward'] * 10**8,
      finder: share[:subscription].user.nickname,
      user_id: share[:subscription].user.id,
      time_spent: Time.now.utc - @last_block_at,
      confirmations: block['confirmations'],
      switchpool: server.switchpool
    )
    puts b.errors.messages.inspect unless b.valid?
    @last_block_at = Time.now.utc
    save_block_payouts(b)
  end

  def save_block_payouts(block)
    scope = server.currency.worker_stats.joins(:worker).where('d1a > 0')
    total_d1a = scope.sum(:d1a)
    server.log "Saving rewards for #{scope.count} miners"
    scope.group('workers.user_id').
    select('workers.user_id as user_id, sum(d1a) as amount').
    order(nil).each do |stat|
      prop = stat.amount / total_d1a.to_f
      user = User.find(stat.user_id)
      reward = (block.reward * prop / 10 ** 8) .round(2)
      server.log "Payout for #{user.nickname}: #{reward} #{server.currency.name}"
      block.block_payouts.create(
        user_id: stat.user_id,
        amount: prop
      )
    end
  end
end
