module Rack
  class Request
    def trusted_proxy?(ip)
      ip == '95.211.38.220'
    end
  end
end

Rack::Attack.throttle('req/ip', :limit => 20, :period => 4.seconds) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.

  Rails.env.development? ? false : req.ip
end
