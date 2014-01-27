class Pool::TemplateRegistry
  attr_accessor :extranonce2_size

  def initialize(pool)
    @jobs = []
    @pool = pool
    @prevhashes = {}
    @job_counter = 0
    @instance_id = 31
    @extranonce1_size = 4
    @extranonce1_counter = @instance_id << 27
    @extranonce2_size = 4
    @update_in_progress = false
  end

  def get_new_job_id
    @job_counter = 0 if @job_counter % 0xFFFF == 0
    @job_counter += 1
    @job_counter.to_s(16)
  end

  def get_new_extranonce1
    @extranonce1_counter += 1
    [@extranonce1_counter].pack('L>')
  end

  def get_last_bcast_args
    @lastblock.try(:broadcast_args)
  end

  def add_template(block, block_height)
    new_block = false
    prevhash = block.prevhash_hex
    unless @prevhashes[prevhash]
      new_block = true
      @prevhashes[prevhash] = []
    end

    @prevhashes[prevhash] << block
    @jobs[block.job_id.hex] = block
    @lastblock = block
    @prevhashes.each { |ph, b| @prevhashes.delete ph unless ph == prevhash }

    @pool.log "New template for #{prevhash}"
    @pool.on_template(new_block)
  end

  def update_block
    return if @update_in_progress
    @update_in_progress = true
    data = @pool.rpc.getblocktemplate(mode: 'template')
    return unless data.try(:[], 'previousblockhash')
    return @update_in_progress = false if @lasthash == data['previousblockhash']

    @lasthash = data['previousblockhash']
    start = Time.now

    template = Pool::BlockTemplate.new(@pool, get_new_job_id)
    template.fill_from_rpc(data)

    @jobs = []
    add_template(template, data['height'])

    timespent = (Time.now - start).round(2)
    @pool.log "Update finished, #{timespent} sec, #{template.tx.count} txes"
  rescue => e
    @pool.log "Block update failed: #{e.inspect}"
    @pool.log e.backtrace
  ensure
    @update_in_progress = false
  end

  def diff2target(diff)
    return 0 unless diff.try(:>, 0)
    case @pool.algo
    when 'scrypt'
      base = '0000ffff00000000000000000000000000000000000000000000000000000000'
    when 'sha256'
      base = '00000000ffff0000000000000000000000000000000000000000000000000000'
    end
    base.hex / diff
  end

  def get_job(job_id)
    return unless job = @jobs[job_id.hex]
    unless prevhash = @prevhashes[job.prevhash_hex]
      @pool.log "Prevhash of job #{job_id} is unknown"
      return
    end
    @pool.log "Job #{job_id} is unknown" unless prevhash.include? job
    return job
  end

  def submit_share(conn, sub, job_id, extranonce2, time, nonce)
    return unless job_id && sub.authorized

    username = sub.worker.name
    extranonce1_bin = sub.extranonce1_bin

    share = {
      time: Time.now,
      username: username,
      diff: 0,
      diff_target: sub.min_diff,
      accepted: false,
      upstream: false,
      subscription: sub
    }

    if extranonce2.size != @extranonce2_size * 2
      share[:reject_reason] = "Incorrect size of extranonce2, expected " +
        "#{@extranonce2_size*2} chars, got #{extranonce2.length}"
      conn.reject(share[:reject_reason])
      return @pool.sharelogger.log_share(share)
    end

    job = get_job(job_id)

    unless job
      share[:reject_reason] = "Job #{job_id} not found"
      conn.reject(share[:reject_reason])
      return @pool.sharelogger.log_share(share)
    end

    unless time.size == 8
      share[:reject_reason] = "Incorrect size of ntime, expected 8 bytes"
      conn.reject(share[:reject_reason])
      return @pool.sharelogger.log_share(share)
    end

    unless job.check_time(time.hex)
      share[:reject_reason] = "Ntime out of range"
      conn.reject(share[:reject_reason])
      return @pool.sharelogger.log_share(share)
    end

    unless nonce.size == 8
      share[:reject_reason] = "Incorrect size of nonce, expected 8 bytes"
      conn.reject(share[:reject_reason])
      return @pool.sharelogger.log_share(share)
    end

    unless job.register_submit(extranonce1_bin, extranonce2, time, nonce)
      share[:duplicate] = true
      share[:reject_reason] = "Duplicate share"
      # conn.reject(share[:reject_reason])
      # return @pool.sharelogger.log_share(share)
    end

    time_bin = Pool::Util.unhexlify time
    nonce_bin = Pool::Util.unhexlify nonce
    puts "time_bin: #{Pool::Util.hexlify(time_bin)} | nonce_bin: #{Pool::Util.hexlify(nonce_bin)}"
    extranonce2_bin = Pool::Util.unhexlify extranonce2
    puts "extranonce2_bin: #{Pool::Util.hexlify(extranonce2_bin)}"

    coinbase_bin = job.serialize_coinbase(extranonce1_bin, extranonce2_bin)
    puts "coinbase_bin: #{Pool::Util.hexlify(coinbase_bin)}"
    coinbase_hash = Pool::Util.dblsha(coinbase_bin)
    puts "coinbase_hash: #{Pool::Util.hexlify(coinbase_hash)}"

    merkleroot_bin = job.merkletree.with_first(coinbase_hash)
    puts "merkleroot_bin: #{Pool::Util.hexlify(merkleroot_bin)}"
    merkleroot_int = Pool::Util.deser_uint256(merkleroot_bin)
    puts "merkleroot_int: #{merkleroot_int}"

    header_bin = job.serialize_header(merkleroot_int, time_bin, nonce_bin)
    puts "header_bin: #{Pool::Util.hexlify(header_bin)}"

    case @pool.algo
    when 'scrypt'
      hash_bin = Pool::Util.scrypt(Pool::Util.reverse_bin(header_bin, 4))
    when 'sha256'
      hash_bin = Pool::Util.dblsha(Pool::Util.reverse_bin(header_bin, 4))
    end
    puts "hash_bin: #{Pool::Util.hexlify(hash_bin)}"

    hash_int = Pool::Util.deser_uint256(hash_bin)
    puts "hash_int: #{hash_int}"
    hash_hex = hash_int.to_s(16)
    share[:hash] = sprintf("%064x", hash_int)
    header_hex = Pool::Util.hexlify(header_bin)

    puts "diff_target: #{share[:diff_target]}"
    target_user = diff2target(share[:diff_target])
    puts  "target_user: #{target_user}"
    share[:diff] = diff2target(hash_int)

    if hash_int > target_user
      share[:reject_reason] = "Share is above target"
      conn.reject(share[:reject_reason])
      return @pool.sharelogger.log_share(share)
    end

    share[:accepted] = true
    conn.reply(true)

    if hash_int < job.target
      job.finalize(merkleroot_int, extranonce1_bin, extranonce2_bin, time.hex, nonce.hex)
      share[:block_hash] = @pool.pos ? share[:hash] : job.calc_sha256_hex

      @pool.log("Block candidate: #{share[:block_hash]}")

      return @pool.log("Final job validation failed!") unless job.valid?

      serialized = Pool::Util.hexlify(job.serialize)
      submit_block(share, serialized)
    else
      @pool.sharelogger.log_share(share)
    end

  rescue => e
    @pool.log "Exception in submit_share: #{e.inspect}"
    @pool.log e.backtrace
  end

  def submit_block(share, block_hex)
    begin
      result = @pool.rpc.submitblock(block_hex)
    rescue => e
      @pool.log e.inspect
      @pool.log e.backtrace
      submit_block_gbt(share, block_hex)
    else
      block_post_submit share, result
    end
  end

  def submit_block_gbt(share, block_hex)
    begin
      result = @pool.rpc.getblocktemplate({ mode: 'submit', data: block_hex })
    rescue => e
      @pool.log e.inspect
      @pool.log e.backtrace
      block_post_submit share, e
    else
      block_post_submit share, result
    end
  end

  def block_post_submit(share, response = nil)
    puts 'block_post_submit'
    puts response
    if response && response != true
      share[:upstream_reason] = response
      @pool.sharelogger.log_share(share)
    else
      check_found_block(share)
      update_block
    end
  end

  def check_found_block(share)
    puts 'check_found_block'
    block = @pool.rpc.getblock(share[:block_hash])
  rescue => e
    @pool.log e.inspect
    @pool.log e.backtrace
    @pool.sharelogger.log_share(share)
  else
    check_block_tx(share, block)
  end

  def check_block_tx(share, block)
    txid = block.try(:[], 'tx').try(:[], 0)
    raise 'No TXID' unless txid.try(:size) == 64
    tx = @pool.rpc.gettransaction txid
    details = tx.try(:[], 'details').try(:[], 0)
    raise 'No TX details' unless details.try(:size)
    raise 'Bad category' unless %w(immature generate).include? details['category']
    share[:upstream] = true
    block['reward'] = details['amount']
    block['address'] = details['address']
    block['category'] = details['category']
    @pool.sharelogger.log_block(share, block)
  rescue => e
    @pool.log e.inspect
    @pool.log e.backtrace
    @pool.sharelogger.log_share(share)
  end
end
