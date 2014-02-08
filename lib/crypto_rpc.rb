class CryptoRPC
  def initialize(currency)
    @currency = currency
    @url  = "http://#{currency.host}:#{currency.port}"
    @auth = { username: currency.user, password: currency.pass }
  end

  def construct_rpc(method, args)
    {
      timeout: 5,
      port: @currency.port,
      basic_auth: @auth,
      body: MultiJson.dump({
        id: "cx-#{SecureRandom.hex(16)}",
        jsonrpc: '1.0',
        method: method.to_s,
        params: args
      })
    }
  end

  def api_call(method, args = [])
    r = HTTParty.post(@url, construct_rpc(method, args))
    err = r.parsed_response.try(:[], 'error').try(:[], 'message')
    raise err if err
    r.parsed_response.try(:[], 'result')

  rescue URI::InvalidURIError
    puts "[#{Time.now}] #{@currency.name}: invalid RPC URL"
  rescue Errno::ECONNREFUSED
    puts "[#{Time.now}] #{@currency.name}: connection refused"
  rescue Errno::EHOSTDOWN
    puts "[#{Time.now}] #{@currency.name}: host down"
  rescue Timeout::Error
    puts "[#{Time.now}] #{@currency.name}: failed to connect"
  rescue Errno::EHOSTUNREACH
    puts "[#{Time.now}] #{@currency.name}: host unreachable"
  rescue Errno::EPIPE
    puts "[#{Time.now}] #{@currency.name}: broken pipe"
  rescue => e
    info = err ? err : e.inspect
    puts "[#{Time.now}] #{@currency.name}: request failed: #{info}"
    puts "method: #{method}, params: #{args.join(', ')}"
    puts "stack: #{e.backtrace.join("\n")}" unless err
  end

  def method_missing(method, *args)
    self.api_call(method, args)
  end
end
