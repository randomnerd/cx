class Pool::Subscription
  attr_accessor :min_diff, :diff, :extranonce1_bin, :extranonce1_hex,
                :authorized, :user, :worker, :server, :stats

  def initialize(connection, request, diff = 1)
    @key = SecureRandom.hex(16)
    @diff = diff
    @user = nil
    @stats = nil
    @worker = nil
    @server = connection.server
    @submits = 0
    @currency = @server.currency
    @hrate_d1a = 0
    @prev_diff = nil
    @connection = connection
    @authorized = false
    @flush_interval = @server.worker_stats_interval
    @extranonce1_bin = @server.registry.get_new_extranonce1
    @extranonce1_hex = Pool::Util.hexlify(@extranonce1_bin)
    @last_diff_update = nil
    @last_rate_update = Time.now.utc
    @last_stats_flush = Time.now.utc
    @extranonce2_size = @server.registry.extranonce2_size
  end

  def set_diff(diff)
    diff = 1
    @server.log "Setting diff #{diff} for #{worker.name}"
    @prev_diff = @diff
    @diff = diff
    @min_diff = [@diff, @prev_diff].min
    @last_diff_update = Time.now
    @connection.set_difficulty(@diff)
    args = @server.registry.get_last_bcast_args
    return unless args
    args[args.size - 1] = true
    stats.diff = @diff
    @connection.notify(args)
  rescue => e
    puts e.inspect
    puts e.backtrace
  end

  def shares_per_min
    @submits / mins_since_last_diff_upd
  end

  def flush_stats(force = false)
    return unless stats
    return unless @last_stats_flush <= @flush_interval.seconds.ago.utc || force
    stats.save
    @last_stats_flush = Time.now.utc
  end

  def update_stats(share)
    if share[:accepted]
      stats.accepted += share[:diff_target]
      stats.d1a += share[:diff_target]
    else
      stats.rejected += share[:diff_target]
    end
    stats.blocks += 1 if share[:upstream]
    update_diff
    update_hashrate(share)
    flush_stats
  end

  def update_hashrate(share, timespan_limit = 10.minutes)
    @hrate_d1a += share[:diff_target]
    timespan = Time.now - @last_rate_update
    if timespan > timespan_limit
      tdiff = timespan - timespan_limit
      hdiff = timespan_limit / timespan.to_f
      @hrate_d1a = @hrate_d1a * hdiff
      timespan = timespan_limit
      @last_rate_update += tdiff
    end

    return 0 unless timespan >= 15
    case @currency.algo
    when 'scrypt'
      dmulti = 67108864
      hmulti = 1000000
    when 'sha256'
      dmulti = 4294967296
      hmulti = 1000
    end
    stats.hashrate = @hrate_d1a * dmulti / timespan / hmulti
  end

  def mins_since_last_diff_upd
    (Time.now - @last_diff_update) / 60
  end

  def start
    [ [ 'mining.notify', @key ], @extranonce1_hex, @extranonce2_size ]
  end

  def update_diff
    min     = server.difficulty
    max     = server.vardiff_max
    per_min = server.vardiff_shares_per_min
    window  = server.vardiff_window
    @submits += 1
    return unless mins_since_last_diff_upd >= window
    new_diff = [min, (shares_per_min / per_min * @diff)].max
    return if new_diff == @diff
    @submits = 0
    set_diff [new_diff, max].min
  end
end
