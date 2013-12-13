class ProcessPool
  include Sidekiq::Worker

  def perform(cid)
    cache_key = "pool_#{cid}_processing"
    return if Rails.cache.read cache_key
    Rails.cache.write cache_key, true
    currency = Currency.find(cid)

    puts "[#{Time.now}] Processing #{currency.name} mining"
    currency.process_mining
    puts "[#{Time.now}] Processing #{currency.name} mining: done"
  rescue => e
    case e
    when URI::InvalidURIError
      puts "[#{Time.now}] Processing #{currency.name} mining: invalid RPC URL"
    when Errno::ECONNREFUSED
      puts "[#{Time.now}] Processing #{currency.name} mining: connection refused"
    when Errno::EHOSTDOWN
      puts "[#{Time.now}] Processing #{currency.name} mining: host down"
    when Timeout::Error
      puts "[#{Time.now}] Processing #{currency.name} mining: failed to connect"
    when Errno::EHOSTUNREACH
      puts "[#{Time.now}] Processing #{currency.name} mining: host unreachable"
    else
      puts e.inspect
      puts e.backtrace
    end
  ensure
    Rails.cache.write cache_key, false
  end
end
