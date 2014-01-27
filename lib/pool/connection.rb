class Pool::Connection < JsonRPC::Server
  attr_accessor :server, :subscription

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

  def log(message)
    server.log(message)
  end

  def unbind
    server.connections.delete self
    return unless @subscription
    @subscription.stats.update_attributes accepted: 0, rejected: 0, blocks: 0
  end

  def send_json(data, close = false)
    send_data JrJackson::Json.dump(data.to_json) + "\n"
    close_connection_after_writing if close
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
