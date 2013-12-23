def process_withdrawals(curr, skip = 0, batch = 100, unk = 0)
  txs = curr.rpc.listtransactions('*', batch, skip)
  return unless txs
  return if txs.try(:count) == 0

  txs.reverse.each do |tx|
    return unk if tx['category'] == 'move' && tx['account'] == 'stop_processing_here'
    next unless tx['category'] == 'send'
    next if Withdrawal.find_by_txid(tx['txid'])
    uid = tx['account'].match(/.*-(\d+)/).try(:[], 1).try(:to_i)
    next unless uid
    user = User.find(uid)
    amt = ((tx['amount'] - curr.tx_fee) * 10 ** 8).abs
    puts "Unknown withdrawal for #{tx['amount']}, user #{user.nickname} || #{(amt.to_f / 10 ** 8).round(8)}"
    gotcha = false
    user.withdrawals.where(currency_id: curr.id, txid: nil).each do |w|
      gotcha = (w.amount.to_f / 10 ** 8).round(8) == (amt.to_f / 10 ** 8).round(8)
      if gotcha
        puts 'gotcha!'
        w.txid = tx['txid']
        w.failed = false
        w.processed = true
        w.save(validate: false)
        if bc = BalanceChange.where(subject: w).where('amount > 0').first
          puts 'was refunded'
          bc.delete
          bc.balance.verify!
          puts 'refund rolled back'
        end
        break
      else
        puts "#{w.amount.to_f / 10 ** 8} != #{(amt.to_f / 10 ** 8).round(8)}"
      end
    end
    unless gotcha
      w = user.withdrawals.build({
        currency_id: curr.id,
        amount: amt,
        txid: tx['txid'],
        processed: true,
        failed: false,
        address: tx['address']
      })
      w.save(validate: false)
      w.balance.add_funds(-amt, w)
    end
    unk += tx['amount']
  end
  process(curr, skip + batch, batch, unk)
rescue => e
  puts e.inspect
  puts e.backtrace
  0
end

def process_deposits(curr, skip = 0, batch = 100, unk = 0)
  txs = curr.rpc.listtransactions('*', batch, skip)
  return unless txs
  return if txs.try(:count) == 0

  txs.reverse.each do |tx|
    return unk if tx['category'] == 'move' && tx['account'] == 'stop_processing_here'
    next unless tx['category'] == 'receive'
    dep = Deposit.find_by_txid(tx['txid'])
    next unless dep
    puts BalanceChange.where(subject: dep).count
  end
  process(curr, skip + batch, batch, unk)
rescue => e
  puts e.inspect
  puts e.backtrace
  0
end

i = 0
Order.find_each { |o|
  next if o.trades.sum(:amount) == o.amount
  real = o.amount.to_f / 10 ** 8
  actual = o.trades.sum(:amount).to_f / 10 ** 8
  next unless actual > real
  puts "#{o.trade_pair.currency.name}, #{real} | #{actual}"
  amt = 0
  o.trades.each { |t|
    amt += t.amount
    next if amt <= o.amount
    t.delete
    BalanceChange.where(subject: t).each {|bc|
      bc.delete
      bc.balance.verify!
    }
  }
}

Withdrawal.where('txid is not null').find_each {|w|
  bcs = BalanceChange.where(subject: w)
  next unless bcs.count > 1
  puts bcs.where('amount > 0').each {|bc|
    bc.delete
    bc.balance.verify!
  }
}

Withdrawal.where(txid:nil).each { |w|
  begin
  amt = (w.amount.to_f) / 10**8 - w.currency.tx_fee
  w.currency.rpc.listtransactions("user-#{w.user_id}", 10000).select {|t|
    t['category'] == 'send' && t['amount'].abs == amt
  }.each { |t|
    puts "#{amt} | #{t['amount']}"
    tx = Withdrawal.find_by_txid(t['txid'])
    if tx
      puts 'unprocessed'
      next
    else
      puts 'processed'
      if w.txid && !w.txid.empty?
        puts 'create new'
        next
        ww = w.user.withdrwawals.create({
          processed: true,
          txid: t['txid'],
          currency_id: w.currency_id,
          address: t['address']
        })
        w.balance.add_funds(-w.amount, ww)
      else
        puts 'assign txid'
        w.txid = t['txid']
        puts w.update_attributes txid: t['txid'], failed: false
        puts w.save(validate:false)
      end
    end
  }
  next if w.txid
  puts 'refund'
  next
  w.update_attributes failed: true
  w.balance.add_funds(w.amount, w)
  w.user.notifications.create(
    title: "#{w.currency.name} withdrawal failed",
    body: "#{w.amount.to_f/10**8} #{w.currency.name} were credited back to your account"
  )
  rescue => e
    next
  end
}


BalanceChange.where(subject_type: 'Withdrawal').
group('balance_id, subject_id, subject_type').
select('count(id) as count, balance_id, subject_id, subject_type').
map {|bc|
  next if bc.count == 1
  #BalanceChange.where(balance_id: bc.balance_id).where(subject: bc.subject).limit(bc.count - 1).each &:delete
  #bc.balance.verify!
  [bc.count, bc.balance.user.nickname, bc.count - 1]
}.compact



BalanceChange.where(subject_type: 'Trade', comment: 'unlock_funds(move=false)').
group('balance_id, subject_id, subject_type').
select('count(id) as count, balance_id, subject_id, subject_type').
map {|bc|
  next if bc.count == 1
  #BalanceChange.where(balance_id: bc.balance_id).where(subject: bc.subject).limit(bc.count - 1).each &:delete
  #bc.balance.verify!
  [bc.count, bc.balance.user.nickname, bc.count - 1]
}.compact


r = BalanceChange.where(subject_type: 'Trade').
group('subject_id, subject_type').
select('id, count(id) as count, balance_id, subject_id, subject_type, amount, held').
map {|bc|
  next if bc.count >= 4
  t = bc.subject
  unless t
    puts bc.inspect
    next
  end
  next if t.ask_user_id == t.bid_user_id
  bcs = BalanceChange.where(subject: t)
  i = {id: bc.subject_id, count: bc.count}
  i[:ask_cur] = bcs.where(balance: t.ask_user.balance_for(t.currency_id)).first
  i[:bid_cur] = bcs.where(balance: t.bid_user.balance_for(t.currency_id)).first
  i[:bid_mkt] = bcs.where(balance: t.bid_user.balance_for(t.market_id)).first
  i[:ask_mkt] = bcs.where(balance: t.ask_user.balance_for(t.market_id)).first
  unless i[:ask_cur]
    t.ask_user.balance_for(t.currency_id).unlock_funds(t.amount, t, false)
  end
  unless i[:bid_cur]
    t.bid_user.balance_for(t.currency_id).add_funds(t.amount - t.bid_fee, t)
  end
  unless i[:bid_mkt]
    t.bid_user.balance_for(t.market_id).unlock_funds(t.market_amount, t, false)
  end
  unless i[:ask_mkt]
    t.ask_user.balance_for(t.market_id).add_funds(t.market_amount - t.ask_fee, t)
  end

  i
}.compact;0





BalanceChange.where(subject_type: 'Order').
group('balance_id, subject_id, subject_type, amount, held').
select('count(id) as count, balance_id, subject_id, subject_type, amount, held').
map {|bc|
  next if bc.count == 1
  # BalanceChange.where(balance_id: bc.balance_id, subject: bc.subject).
  # where(amount: bc.amount, held: bc.held).
  # limit(bc.count - 1).each &:delete
  # bc.balance.verify!
  [bc.count, bc.balance.user.nickname]
}.compact


Trade.joins('right outer join balance_changes on balance_changes.subject_id = trades.id and balance_changes.subject_type="Trade"').
where('trades.id is null').count

Balance.where('held < 0').each {|b|
  b.balance_changes.create(held: b.held.abs, t_held: 0, amount: b.held, t_amount: b.amount + b.held, comment: 'extra trades pulled')
  b.verify!
}
