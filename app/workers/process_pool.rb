class ProcessPool
  include Sidekiq::Worker
  sidekiq_options queue: :pools, retry: false

  def perform(cid)
    cache_key = "pool_#{cid}_processing"
    return if Rails.cache.read cache_key
    Rails.cache.write cache_key, true
    currency = Currency.find(cid)

    puts "[#{Time.now}] Processing #{currency.name} mining"
    currency.process_mining
    puts "[#{Time.now}] Processing #{currency.name} mining: done"
  rescue => e
    puts e.inspect
    puts e.backtrace
  ensure
    Rails.cache.write cache_key, false
  end
end
