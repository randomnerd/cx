class ProcessCurrency
  include Sidekiq::Worker
  sidekiq_options queue: :currencies, retry: false

  def perform(cid)
    cache_key = "currency_#{cid}_processing"
    return if Rails.cache.read cache_key
    Rails.cache.write cache_key, true
    currency = Currency.find(cid)

    puts "[#{Time.now}] Processing #{currency.name}"
    currency.process_transactions
    puts "[#{Time.now}] Processing #{currency.name}: done"

  rescue => e
    case e
    when URI::InvalidURIError
      puts "[#{Time.now}] Processing #{currency.name}: invalid RPC URL"
    when Errno::ECONNREFUSED
      puts "[#{Time.now}] Processing #{currency.name}: connection refused"
    when Errno::EHOSTDOWN
      puts "[#{Time.now}] Processing #{currency.name}: host down"
    when Timeout::Error
      puts "[#{Time.now}] Processing #{currency.name}: failed to connect"
    when Errno::EHOSTUNREACH
      puts "[#{Time.now}] Processing #{currency.name}: host unreachable"
    when Errno::EPIPE
      puts "[#{Time.now}] Processing #{currency.name}: broken pipe"
    else
      puts e.inspect
      puts e.backtrace
    end
  ensure
    Rails.cache.write cache_key, false
  end
end
