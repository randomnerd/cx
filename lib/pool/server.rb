class Pool::Server
  include Celluloid::IO
  finalizer :shutdown
  trap_exit :shutdown
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
    @registry = Pool::TemplateRegistry.new(Celluloid::Actor.current)
    @coinbaser = Pool::Coinbaser.new(Celluloid::Actor.current)
    @sharelogger = Pool::Sharelogger.new(Celluloid::Actor.current)
    @server = TCPServer.new(@listen, @port)
    @registry.update_block
    async.update_timers
    async.run
  end

  def update_timers
    @block_updater = every(1) { @registry.update_block }
    @hashrate_updater = every(1.minute) {
      rate = @currency.worker_stats.active.sum(:hashrate)
      @currency.update_attribute :hashrate, rate
      log "Pool hashrate: #{rate}"
    }
  end

  def shutdown
    @block_updater.cancel
    @server.close rescue nil
    @connections.each &:disconnect!
    @connections = []
  rescue => e
    puts e.inspect
    puts e.backtrace.join("\n")
  ensure
    terminate rescue nil
  end

  def handle_connection(socket)
    connection = Pool::Connection.new(Celluloid::Actor.current, socket)
    @connections << connection
    loop {
      request  = socket.readline
      response = connection.receive_data(request)
    }
  rescue
    connection.disconnect!
  end

  def send_data_async(connection, data, close = false)
    async.send_data(connection, data, close = false)
  end

  def send_data(connection, data, close = false)
    connection.socket.puts data
    connection.disconnect! if close
  rescue => e
    connection.disconnect!
  end

  def run
    loop { async.handle_connection @server.accept }
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
    @connections.each { |conn| conn.subscription.flush_stats(true) }
  end

  def reset_d1a
    @currency.worker_stats.update_all d1a: 0
    @connections.each { |conn| conn.subscription.stats.d1a = 0 }
  end

  def broadcast(event, params)
    @connections.each { |conn| conn.send_event(event, params) }
  end
end
