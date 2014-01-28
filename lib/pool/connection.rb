class Pool::Connection
  include Celluloid::IO
  finalizer :shutdown
  attr_accessor :server, :subscription, :host, :port

  def initialize(server, socket)
    @server = server
    @socket = socket
    _, @port, @host = socket.peeraddr
    @server.log "*** Received connection from #{host}:#{port}"
    async.run
  end

  def shutdown
    @subscription.try(:flush_stats, true)
    @socket.close if @socket
    handle_disconnect
  end

  def run
    loop { receive_data(@socket.readline) }

  rescue Errno::ECONNRESET then handle_disconnect
  rescue EOFError then handle_disconnect
  end

  def handle_disconnect
    server.connections.delete self
    return unless @subscription
    @subscription.stats.update_attributes accepted: 0, rejected: 0, blocks: 0
    @server.log "*** #{@host}:#{@port} disconnected"
  end

  def receive_data(data)
    process_request JrJackson::Json.load(data, symbolize_keys: true)
  rescue => e
    @socket.puts "Request parsing error"
    parsing_error e, data
  end

  def process_request(data)
    receive_request Pool::Request.new(self, data[:id], data[:method], data[:params])
  end

  def parsing_error(error, data)
    puts "Error parsing data: #{data.inspect}"
    puts error.inspect
    puts error.backtrace
  end


  def receive_request(request)
    case request.rpc_method
    when 'mining.subscribe'     then subscribe(request)
    when 'mining.authorize'     then authorize(request)
    when 'mining.update_block'  then update_block(request)
    when 'mining.submit'        then submit(request)
    end
  end

  def subscribe(request)
    return request.reject("Already subscribed") if @subscription
    @subscription = Pool::Subscription.new(self, request)
    request.reply @subscription.start
  end

  def authorize(request)
    user, pass = request.params
    if user && pass && worker = Worker.where(name: user, pass: pass).first
      request.reply(true)
      @subscription.worker = worker
      @subscription.authorized = true
      @subscription.user = worker.user
      server.log "Miner authorized: #{user} / #{pass}"
      diff = @subscription.stats.diff
      @subscription.set_diff(diff > 0 ? diff : server.difficulty)
    else
      request.reply(false, true)
      server.log "Miner rejected: #{user} / #{pass}"
    end
  end

  def update_block(request)
    # stub
  end

  def submit(request)
    username, job_id, extranonce2, ntime, nonce = request.params
    server.registry.submit_share(
      request, @subscription, job_id, extranonce2, ntime, nonce
    )
  end

  def send_json(data, close = false)
    @socket.puts JrJackson::Json.dump(data)
    @socket.close if close
  end

  def send_event(event, params)
    data = {
      id: nil,
      method: event,
      params: params
    }
    send_json data
  end

  def notify(params)
    send_event 'mining.notify', params
  end

  def reply(result, close = false)
    return nil if error?

    response = {
      id: id,
      result: result,
      error: nil
    }

    send_json response, close
  rescue => e
    puts e.inspect
    puts e.backtrace
  end

  def set_difficulty(diff)
    send_event('mining.set_difficulty', [diff])
  end
end
