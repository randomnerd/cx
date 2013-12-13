class CryptoRPC
  def initialize(currency)
    @currency = currency
    @url  = "http://#{currency.host}:#{currency.port}"
    @auth = { username: currency.user, password: currency.pass }
  end

  def construct_rpc(method, args)
    {
      timeout: 500,
      port: @currency.port,
      basic_auth: @auth,
      body: {
        id: "cx-#{SecureRandom.hex(16)}",
        jsonrpc: '1.0',
        method: method.to_s,
        params: args
      }.to_json
    }
  end

  def api_call(method, args = [])
    r = HTTParty.post(@url, construct_rpc(method, args))
    throw r.parsed_response['error'] if r.parsed_response.try(:[], 'error')
    r.parsed_response.try(:[], 'result')
  end

  def method_missing(method, *args)
    self.api_call(method, args)
  end
end
