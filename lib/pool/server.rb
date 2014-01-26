class Pool::Server
  attr_accessor :connections, :currency, :rpc, :pos, :algo, :tx_msg,
                :coinbaser, :sharelogger, :registry, :mining_address,
                :difficulty, :vardiff_max, :vardiff_window, :switchpool,
                :vardiff_shares_per_min, :worker_stats_interval

  def initialize(currency)
    currency  = Currency.find(currency) if currency.kind_of? Fixnum
    @currency = currency
    @rpc      = currency.rpc
    @pos      = currency.mining_pos
    @algo     = currency.algo
    @port     = currency.mining_port
    @tx_msg   = currency.mining_txmsg
    @listen   = '0.0.0.0'
    @mining_address  = currency.mining_address
    @difficulty = 32
    @switchpool = false
    @vardiff_max = 1024
    @vardiff_window = 1
    @worker_stats_interval = 15
    @vardiff_shares_per_min = 10

    @connections = []
    @registry = Pool::TemplateRegistry.new(self)
    @coinbaser = Pool::Coinbaser.new(self)
    @sharelogger = Pool::Sharelogger.new(self)
  end

  def start
    @signature = EM.start_server(@listen, @port, Pool::Connection) do |conn|
      puts "New connection"
      conn.server = self
      @connections << conn
      conn.set_comm_inactivity_timeout 0
    end
    @block_updater = EM.add_periodic_timer(1) { @registry.update_block }
    @hashrate_updater = EM.add_periodic_timer(1.minute) {
      rate = @currency.worker_stats.active.sum(:hashrate)
      @currency.update_attribute :hashrate, rate
      log "Pool hashrate: #{rate}"
    }
  end

  def stop
    EM.stop_server(@signature)
    @block_updater.cancel
    @hashrate_updater.cancel
  end

  def log(message)
    puts message
  end

  def on_template(new_block)
    args = @registry.get_last_bcast_args
    return unless args
    args[args.size - 1] = new_block

    broadcast('mining.notify', args)
  end

  def on_block(share, block)
    @currency.worker_stats.update_all d1a: 0
    @connections.each { |conn| conn.subscription.stats.d1a = 0 }
  end

  def broadcast(event, params)
    @connections.each { |conn| conn.send_event(event, params) }
  end
end
