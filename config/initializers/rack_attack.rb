Rack::Attack.throttle('req/api/ip', :limit => 1, :period => 1.second) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.
  req.ip if req.env['HTTP_API_KEY'].present?
end


Rack::Attack.throttle('req/ip', :limit => 40, :period => 4.seconds) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.
  unless req.env['HTTP_API_KEY'].present?
    Rails.env.development? ? false : req.ip
  end
end
